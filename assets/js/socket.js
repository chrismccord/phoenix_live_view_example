import {Socket} from "./phoenix"
import morphdom from "morphdom"

const PHX_VIEW_SELECTOR = "[data-phx-view]"
const PHX_HAS_FOCUSED = "phx-has-focused"
const FOCUSABLE_INPUTS = ["text", "textarea", "password"]
const PHX_HAS_SUBMITTED = "phx-has-submitted"
const PARAMS_SELECTOR = "data-params"
const SESSION_SELECTOR = "data-session"
const LOADER_TIMEOUT = 100
const LOADER_ZOOM = 2

let socket = new Socket("/socket")
window.socket = socket
socket.connect()

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

let handleClick = (el, view) => {
  let phxEvent = el.getAttribute && el.getAttribute("phx-click")
  if(phxEvent){ 
    el.addEventListener("click", e => view.pushClick(el, e, phxEvent))
  }
}

let handleKeyup = (el, view) => {
  let phxEvent = el.getAttribute && el.getAttribute("phx-keyup")
  if(phxEvent){
    el.addEventListener("keyup", e => view.pushKeyup(el, e, phxEvent))
  }
}

let bindUI = function(view) {
  document.querySelectorAll("form[phx-change] input").forEach(input => {
    let phxEvent = input.form.getAttribute("phx-change")
    input.addEventListener("input", e => {
      if(FOCUSABLE_INPUTS.indexOf(input.type) >= 0){ input.setAttribute(PHX_HAS_FOCUSED, true) }
      view.pushInput(input, e, phxEvent)
    })
  })

  document.querySelectorAll("form[phx-submit]").forEach(form => {
    let phxEvent = form.getAttribute("phx-submit")
    form.addEventListener("submit", e => {
      e.preventDefault()
      form.setAttribute(PHX_HAS_SUBMITTED, "true")
      view.pushFormSubmit(form, e, phxEvent)
    })
  })

  document.querySelectorAll("[phx-click]").forEach(el => handleClick(el, view))
  document.querySelectorAll("[phx-keyup]").forEach(el => handleKeyup(el, view))
}

let discardError = (el) => {
  let field = el.getAttribute && el.getAttribute("phx-error-field")
  if(!field) { return }
  let input = document.getElementById(field)

  if(field && !(input.getAttribute(PHX_HAS_FOCUSED) || input.form.getAttribute(PHX_HAS_SUBMITTED))){
    el.style.display = "none"
  }
}

let joinViewChannels = () => {
  document.querySelectorAll(PHX_VIEW_SELECTOR).forEach(el => {
    let view = new LiveView(el, socket)
    view.join()
  })
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
      discardError(el)
      return el
    },
    onNodeAdded: function(el){
      handleClick(el, view)
      handleKeyup(el, view)
    },
    onBeforeElUpdated: function(fromEl, toEl) {
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

  if(focused.value === ""){ focused.blur()}
  focused.focus()
  if(focused.setSelectionRange && focused.type === "text" || focused.type === "textarea"){
    window.focused = focused
    focused.setSelectionRange(selectionStart, selectionEnd)
  }
  document.dispatchEvent(new Event("phx:update"))
}

class LiveView {
  constructor(el, socket){
    this.el = el
    window.view = this
    this.loader = this.el.nextElementSibling
    this.id = this.el.id
    this.view = this.el.getAttribute("data-view")
    this.hasBoundUI = false
    this.joinParams = {
      params: this.el.getAttribute(PARAMS_SELECTOR),
      session: this.el.getAttribute(SESSION_SELECTOR)
    }
    this.channel = socket.channel(`views:${this.id}`, () => this.joinParams)
    this.loaderTimer = setTimeout(() => this.showLoader(), LOADER_TIMEOUT)
    this.bindChannel()
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
    console.log(middle)
  }
  
  update(html){
    patchDom(this, this.el, this.id, html)
  }

  bindChannel(){
    this.channel.on("render", ({html}) => this.update(html))
    this.channel.on("redirect", ({to, flash}) => redirect(to, flash) )
    this.channel.on("params", ({token}) => this.joinParams.params = token)
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
    this.channel.push("event", {
      type: "form",
      event: phxEvent,
      id: event.target.id,
      value: serializeForm(formEl)
    })
  }
}

document.addEventListener("DOMContentLoaded", () => {
  console.log("joining")
  joinViewChannels()
})

export default socket
