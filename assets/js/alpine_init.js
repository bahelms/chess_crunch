import Alpine from 'alpinejs'
import { objToFen } from 'chessboard-element'

const zeroPad = (val) => {
  const valString = val + ''
  if (valString.length == 2) {
    return valString
  }
  return '0' + valString
}

document.addEventListener('alpine:init', () => {
  Alpine.data('drill', (timeLimit) => ({
    timeLimit,
    seconds: 0,
    timer: null,
    draggablePieces: true,

    init() {
      this.timer = setInterval(() => {
        if (this.seconds >= this.timeLimit) {
          clearInterval(this.timer)
          this.draggablePieces = false
          document.dispatchEvent(new Event('timed_out'))
          return
        }
        this.seconds++
      }, 1000)

      document.addEventListener('stop_drill', () => {
        clearInterval(this.timer)
        this.draggablePieces = false
      })
    },

    reset() {
      this.seconds = 0
      this.timer = setInterval(() => {
        if (this.seconds >= this.timeLimit) {
          clearInterval(this.timer)
          this.draggablePieces = false
          document.dispatchEvent(new Event('timed_out'))
          return
        }
        this.seconds++
      }, 1000)
      this.draggablePieces = true
    },

    secondsToTimeFormat(secs) {
      const mins = zeroPad(parseInt(secs / 60))
      const remainingSecs = zeroPad(secs % 60)
      return `${mins}:${remainingSecs}`
    },
  }))

  Alpine.data('createPosition', () => ({
    fen: '',

    init() {
      this.fen = this.$refs.board.fen()
    },

    captureFen() {
      this.fen = objToFen(this.$event.detail.value)
    },

    selectToPlay(color) {
      this.$refs.board.orientation = color
    },
  }))
})

Alpine.start()
