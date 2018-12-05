import css from "../css/app.css";
import "phoenix_html"
import LiveSocket from "./live_view"

// window.addEventListener("keydown", e => {
//   if(e.which === 32){ e.preventDefault() }
// })

let hooks = {}

window.Email = {
  upcase(e){
    window.e = e
    console.log("app", e)
    e.stopImmediatePropagation()
    e.target.value = e.target.value.toUpperCase()
    console.log("stopping", e.target.value)
  }
}
hooks.Phone = {
  format(input){
    let numbers = input.value.replace(/\D/g, "").split("")
    let char = {0: "", 3: "-", 6: "-"}
    input.value = ""
    numbers.forEach((num, i) => input.value += `${char[i] || ""}${num}`)
    return true
  }
}

let liveSocket = new LiveSocket("/live", {hooks: hooks})
liveSocket.connect()


