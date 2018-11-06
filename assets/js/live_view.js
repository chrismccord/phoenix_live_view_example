import {Socket} from "./phoenix"
import morphdom from "morphdom"

const PHX_VIEW_SELECTOR = "[data-phx-view]"
const PHX_PARENT_ID = "data-phx-parent-id"
const PHX_HAS_FOCUSED = "phx-has-focused"
const PHX_BOUND = "phx-bound"
const FOCUSABLE_INPUTS = ["text", "textarea", "password"]
const PHX_HAS_SUBMITTED = "phx-has-submitted"
const SESSION_SELECTOR = "data-session"
const LOADER_TIMEOUT = 100
const LOADER_ZOOM = 2

export default class LiveSocket {
  constructor(url, opts){
    this.url = url
    this.opts = opts
    this.views = {}
    this.socket = new Socket(url, opts)
  }

  connect(){
    if(["complete", "loaded","interactive"].indexOf(document.readyState) >= 0){
      joinViewChannels()
    } else {
      document.addEventListener("DOMContentLoaded", () => {
        this.joinViewChannels()
      })
    }
    return this.socket.connect()
  }

  disconnect(){ return this.socket.disconnect()}

  channel(topic, params){ return this.socket.channel(topic, params || {}) }

  joinViewChannels(){
    document.querySelectorAll(PHX_VIEW_SELECTOR).forEach(el => this.joinView(el))
  }

  joinView(el, parentView){
    let view = new View(el, this, parentView)
    this.views[view.id] = view
    view.join()
  }

  destroyViewById(id){
    console.log("destroying", id)
    let view = this.views[id]
    if(!view){ throw `cannot destroy view for id ${id} as it does not exist` }
    view.destroy(() => delete this.views[view.id])
  }
}

let setCookie = (name, value) => {
  document.cookie = `${name}=${value}`
}

let getCookie = (name) => {
  return document.cookie.replace(new RegExp(`(?:(?:^|.*;\s*)${name}\s*\=\s*([^;]*).*$)|^.*$`), "$1")
}

let serializeForm = (form) => {
  return((new URLSearchParams(new FormData(form))).toString())
}

let redirect = (toURL, flash) => {
  if(flash){ setCookie("__phoenix_flash__", flash + "; max-age=60000; path=/") }
  window.location = toURL
}

let handleClick = (el, view, from) => {
  let phxEvent = el.getAttribute && el.getAttribute("phx-click")
  if(phxEvent && !el.getAttribute(PHX_BOUND) && view.ownsElement(el)){ 
    el.setAttribute(PHX_BOUND, true)
    el.addEventListener("click", e => view.pushClick(el, e, phxEvent))
  }
}

let handleKeyup = (el, view) => {
  let phxEvent = el.getAttribute && el.getAttribute("phx-keyup")
  if(phxEvent && view.ownsElement(el)){
    el.addEventListener("keyup", e => view.pushKeyup(el, e, phxEvent))
  }
}

let bindUI = function(view) {
  view.eachChild("form[phx-change] input", input => {
    let phxEvent = input.form.getAttribute("phx-change")
    input.addEventListener("input", e => {
      if(isTextualInput(input)){ input.setAttribute(PHX_HAS_FOCUSED, true) }
      view.pushInput(input, e, phxEvent)
    })
  })

  view.eachChild("form[phx-submit]", form => {
    let phxEvent = form.getAttribute("phx-submit")
    form.addEventListener("submit", e => {
      e.preventDefault()
      form.setAttribute(PHX_HAS_SUBMITTED, "true")
      view.pushFormSubmit(form, e, phxEvent)
    })
  })

  view.eachChild("[phx-click]", el => handleClick(el, view))
  view.eachChild("[phx-keyup]", el => handleKeyup(el, view))
}

let discardError = (el) => {
  let field = el.getAttribute && el.getAttribute("phx-error-field")
  if(!field) { return }
  let input = document.getElementById(field)

  if(field && !(input.getAttribute(PHX_HAS_FOCUSED) || input.form.getAttribute(PHX_HAS_SUBMITTED))){
    el.style.display = "none"
  }
}


let isChild = (node) => {
  return node.getAttribute && node.getAttribute(PHX_PARENT_ID)
}

let patchDom = (view, container, id, html) => {
  let focused = document.activeElement
  let focusedValue = focused.value
  let {selectionStart, selectionEnd} = focused
  let div = document.createElement("div")
  div.innerHTML = html

  morphdom(container, div, {
    childrenOnly: true,
    onBeforeNodeAdded: function(el){
      //input handling
      discardError(el)
      return el
    },
    onNodeAdded: function(el){
      // nested view handling
      if(isChild(el)){
        setTimeout(() => view.liveSocket.joinView(el, view), 1)
        return true
      }

      //input handling
      handleClick(el, view)
      handleKeyup(el, view)
    },
    onBeforeNodeDiscarded: function(el){
      // nested view handling
      if(isChild(el)){
        view.liveSocket.destroyViewById(el.id)
        return true
      }
    },
    onBeforeElUpdated: function(fromEl, toEl) {
      // nested view handling
      if(isChild(toEl)){
        return false
      }

      // input handling
      if(fromEl.getAttribute && fromEl.getAttribute(PHX_HAS_SUBMITTED)){
        toEl.setAttribute(PHX_HAS_SUBMITTED, true)
      }
      if(fromEl.getAttribute && fromEl.getAttribute(PHX_HAS_FOCUSED)){
        toEl.setAttribute(PHX_HAS_FOCUSED, true)
      }
      discardError(toEl)

      if(fromEl === focused){
        return false
      } else {
        return true
      }
    }
  })

  if(isTextualInput(focused)){
    if(focused.value === ""){ focused.blur()}
    focused.focus()
    if(focused.setSelectionRange && focused.type === "text" || focused.type === "textarea"){
      focused.setSelectionRange(selectionStart, selectionEnd)
    }
  }
  document.dispatchEvent(new Event("phx:update"))
}

let isTextualInput = (el) => {
  return FOCUSABLE_INPUTS.indexOf(el.type) >= 0
}

class View {
  constructor(el, liveSocket, parentView){
    this.liveSocket = liveSocket
    this.parent = parentView
    this.el = el
    this.loader = this.el.nextElementSibling
    this.id = this.el.id
    this.view = this.el.getAttribute("data-view")
    this.hasBoundUI = false
    this.joinParams = {session: this.getSession()}
    this.channel = this.liveSocket.channel(`views:${this.id}`, () => this.joinParams)
    this.loaderTimer = setTimeout(() => this.showLoader(), LOADER_TIMEOUT)
    this.bindChannel()
  }

  getSession(){
    return this.el.getAttribute(SESSION_SELECTOR)|| this.parent.getSession()
  }

  destroy(callback){
    this.channel.leave()
      .receive("ok", callback)
      .receive("error", callback)
      .receive("timeout", callback)
  }

  hideLoader(){
    clearTimeout(this.loaderTimer)
    this.loader.style.display = "none"
  }

  showLoader(){
    clearTimeout(this.loaderTimer)
    this.el.classList = "phx-disconnected"
    this.loader.style.display = "block"
    let middle = Math.floor(this.el.clientHeight / LOADER_ZOOM)
    this.loader.style.top = `-${middle}px`
  }
  
  update(html){
    patchDom(this, this.el, this.id, html)
  }

  bindChannel(){
    this.channel.on("render", ({html}) => this.update(html))
    this.channel.on("redirect", ({to, flash}) => redirect(to, flash) )
    this.channel.on("session", ({token}) => this.joinParams.session = token)
    this.channel.onError(() => this.onError())
  }

  join(){
    this.channel.join()
      .receive("ok", data => this.onJoin(data))
      .receive("error", resp => this.onJoinError(resp))
  }

  onJoin({html}){
    this.hideLoader()
    this.el.classList = "phx-connected"
    patchDom(this, this.el, this.id, html)
    if(!this.hasBoundUI){ bindUI(this) }
    this.hasBoundUI = true
  }

  onJoinError(resp){
    this.showLoader()
    this.el.classList = "phx-disconnected phx-error"
    console.log("Unable to join", resp)
  }

  onError(){
    document.activeElement.blur()
    this.showLoader()
    this.el.classList = "phx-disconnected phx-error"
  }

  pushClick(clickedElement, event, phxEvent){
    event.preventDefault()
    this.channel.push("event", {
      type: "click",
      event: phxEvent,
      id: clickedElement.id,
      value: clickedElement.getAttribute("phx-value") || clickedElement.value || ""
    })
  }

  pushKeyup(keyElement, event, phxEvent){
    this.channel.push("event", {
      type: "keyup",
      event: phxEvent,
      id: event.target.id,
      value: keyElement.value
    })
  }

  pushInput(inputEl, event, phxEvent){
    this.channel.push("event", {
      type: "form",
      event: phxEvent,
      id: event.target.id,
      value: serializeForm(inputEl.form)
    })
  }
  
  pushFormSubmit(formEl, event, phxEvent){
    event.target.disabled = true
    this.channel.push("event", {
      type: "form",
      event: phxEvent,
      id: event.target.id,
      value: serializeForm(formEl)
    })
  }

  eachChild(selector, each){
    return this.el.querySelectorAll(selector).forEach(child => {
      if(this.ownsElement(child)){ each(child) }
    })
  }

  ownsElement(element){
    return element.closest(PHX_VIEW_SELECTOR).id === this.id
  }
}

