// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import topbar from "topbar"
import {LiveSocket} from "phoenix_live_view"
import "alpinejs"
import "chessboard-element"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
 params: {_csrf_token: csrfToken},
  // make LiveView work nicely with alpinejs
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) {
        window.Alpine.clone(from.__x, to)
      }
    }
  }
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.imageViewer = () => ({
  imageUrl: "",

  fileChosen(event) {
    this.fileToDataUrl(event, (src) => this.imageUrl = src)
  },

  fileToDataUrl(event, callback) {
    if (!event.target.files.length) return

    const reader = new FileReader()
    reader.readAsDataURL(event.target.files[0])
    reader.onload = (e) => callback(e.target.result)
  }
})

window.cycleIndex = () => ({
  modalOpen: false,
  cycle: null,

  selectCycle(cycle_id, completed_on) {
    console.log('completed_on', completed_on)
    this.cycle = cycle_id
    this.modalOpen = (completed_on ? false : true)
  }
})


const zeroPad = (val) => {
  const valString = val + ""
  if (valString.length == 2) {
    return valString
  }
  return "0" + valString
}

window.secondsToTimeFormat = (secs) => {
  const mins = zeroPad(parseInt(secs / 60))
  const remainingSecs = zeroPad(secs % 60)
  return `${mins}:${remainingSecs}`
}
