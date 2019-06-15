import css from "../css/app.css";
import "phoenix_html"
import {LiveSocket, debug} from "phoenix_live_view"
let logger =  function(kind, msg, data) {
  // console.log(`${kind}: ${msg}`, data)
}
let liveSocket = new LiveSocket("/live", {logger: logger})
liveSocket.connect()
window.liveSocket = liveSocket
