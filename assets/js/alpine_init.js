import Alpine from 'alpinejs'
import { objToFen } from 'chessboard-element'

document.addEventListener('alpine:init', () => {
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
