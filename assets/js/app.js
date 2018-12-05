import css from "../css/app.css";
import "phoenix_html"
import LiveSocket from "./live_view"

// window.addEventListener("keydown", e => {
//   if(e.which === 32){ e.preventDefault() }
// })

let liveSocket = new LiveSocket("/live")
liveSocket.connect()


