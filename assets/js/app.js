import css from "../css/app.css";
import "phoenix_html"
import LiveSocket from "./live_view"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()


