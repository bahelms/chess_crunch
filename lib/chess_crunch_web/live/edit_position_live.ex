defmodule ChessCrunchWeb.EditPositionLive do
  use ChessCrunchWeb, :live_view
  alias ChessCrunch.{PGN, Sets}

  defdelegate format_to_play(position, opts), to: Sets
  defdelegate format_to_play(position), to: Sets

  @impl true
  def mount(%{"id" => position_id}, _session, socket) do
    position = Sets.get_position!(position_id)

    {:ok,
     assign(socket,
       position: position,
       changeset: Sets.change_position(position),
       show_solution: false,
       show_position: false,
       solution_fen: position.solution_fen || position.fen,
       solution_color: if(position.solution_fen, do: "blue", else: "red")
     )}
  end

  @impl true
  def handle_event("toggle_solution", _, socket) do
    {:noreply,
     assign(socket, show_solution: !socket.assigns[:show_solution], show_position: false)}
  end

  @impl true
  def handle_event("toggle_position", _, socket) do
    {:noreply,
     assign(socket, show_position: !socket.assigns[:show_position], show_solution: false)}
  end

  @impl true
  def handle_event("save_position", %{"position" => %{"name" => name}}, socket) do
    {:ok, position} =
      socket.assigns[:position]
      |> Sets.update_position(%{name: name})

    {:noreply, assign(socket, position: position, changeset: Sets.change_position(position))}
  end

  @impl true
  def handle_event("set_solution", %{"pgn" => pgn_string, "fen" => fen}, socket) do
    pgn = PGN.new(pgn_string)

    {:ok, position} =
      socket.assigns.position
      |> Sets.update_position(%{solution_moves: pgn.moves, solution_fen: fen})

    {:noreply,
     assign(socket,
       position: position,
       changeset: Sets.change_position(position),
       solution_fen: fen
     )}
  end

  @impl true
  def handle_event("reset_solution", _, %{assigns: assigns} = socket) do
    {:ok, position} =
      Sets.update_position(assigns.position, %{solution_moves: nil, solution_fen: nil})

    socket =
      socket
      |> assign(
        position: position,
        changeset: Sets.change_position(position),
        solution_fen: position.fen
      )
      |> push_event("new_game", %{fen: position.fen})

    {:noreply, socket}
  end
end
