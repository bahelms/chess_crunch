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
import { Socket } from "phoenix"
import topbar from "topbar"
import { LiveSocket } from "phoenix_live_view"
import "alpinejs"
import { objToFen } from "chessboard-element"
import Chess from "chess.js"

const liveViewHooks = {
  chessboard: {
    game: null,
    startGame() {
      const fen = `${this.el.fen()} ${this.el.getAttribute('to-play')} KQkq - 0 1`
      this.game = new Chess(fen)
    },

    updated() {
      this.startGame()
    },

    mounted() {
      this.startGame()

      this.el.addEventListener("drag-start", (e) => {
        const { source, piece, position, orientation } = e.detail

        // only pick up pieces for the side to move
        if ((this.game.turn() === 'w' && piece.search(/^b/) !== -1) ||
            (this.game.turn() === 'b' && piece.search(/^w/) !== -1)) {
          e.preventDefault()
          return
        }
      })

      this.el.addEventListener("drop", (e) => {
        const { source, target, setAction } = e.detail
        const move = this.game.move({ from: source, to: target })
        const duration = this.el.getAttribute('duration')

        // prevent illegal moves
        if (move === null) {
          setAction("snapback")
        }
        this.pushEvent("board_update", { pgn: this.game.pgn(), duration })
      })

      this.el.addEventListener("snap-end", (e) => {
        // update board for special cases: castling, en passant, pawn promotion
        this.el.setPosition(this.game.fen())
      })
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: liveViewHooks,
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

window.cycleIndex = () => ({
  modalOpen: false,
  cycle: null,

  selectCycle(cycle_id, completed_on) {
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

window.objToFen = objToFen
