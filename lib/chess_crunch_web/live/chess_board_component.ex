defmodule ChessCrunchWeb.ChessBoardComponent do
  use Phoenix.LiveComponent
  alias ChessCrunch.Sets

  def update(%{drill: drill} = assigns, socket) do
    socket =
      if drill.position.solution_fen do
        assign(socket, event: "board_update")
      else
        assign(socket, event: "store_moves")
      end

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    if assigns.drill_active do
      ~L"""
      <chess-board
        id="board"
        phx-hook="chessboard"
        event="<%= @event %>"
        position="<%= @fen %>"
        fen="<%= @fen %>"
        orientation="<%= Sets.format_to_play(@drill.position, caps: false) %>"
        draggable-pieces>
      </chess-board>
      """
    else
      ~L"""
      <chess-board
        id="board"
        phx-hook="chessboard"
        event="<%= @event %>"
        position="<%= @fen %>"
        fen="<%= @fen %>"
        orientation="<%= Sets.format_to_play(@drill.position, caps: false) %>">
      </chess-board>
      """
    end
  end
end
