import css from "../css/app.css";
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket, debug, View} from "phoenix_live_view"

let Hooks = {}

Hooks.PhoneNumber = {
  mounted(){
    let pattern = /^(\d{3})(\d{3})(\d{4})$/
    this.el.addEventListener("input", e => {
      let match = this.el.value.replace(/\D/g, "").match(pattern)
      if(match) {
        this.el.value = `${match[1]}-${match[2]}-${match[3]}`
      }
    })
  }
}

let scrollAt = () => {
  let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
  let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
  let clientHeight = document.documentElement.clientHeight

  return scrollTop / (scrollHeight - clientHeight) * 100
}

Hooks.InfiniteScroll = {
  page() { return this.el.dataset.page },
  mounted(){
    this.pending = this.page()
    window.addEventListener("scroll", e => {
      if(this.pending == this.page() && scrollAt() > 90){
        this.pending = this.page() + 1
        this.pushEvent("load-more", {})
      }
    })
  },
  updated(){ this.pending = this.page() }
}

let serializeForm = (form) => {
  let formData = new FormData(form)
  let params = new URLSearchParams()
  for(let [key, val] of formData.entries()){ params.append(key, val) }

  return params.toString()
}

let Params = {
  data: {},
  set(namespace, key, val){
    if(!this.data[namespace]){ this.data[namespace] = {}}
    this.data[namespace][key] = val
  },
  get(namespace){ return this.data[namespace] || {} }
}

Hooks.SavedForm = {
  mounted(){
    this.el.addEventListener("input", e => {
      Params.set(this.viewName, "stashed_form", serializeForm(this.el))
    })
  }
}


let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks})

liveSocket.connect()

