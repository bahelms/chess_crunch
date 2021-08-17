defmodule ChessCrunchWeb.CycleLive do
  use ChessCrunchWeb, :live_view
  alias ChessCrunch.{PGN, Cycles, Drills, Sets}

  defdelegate format_to_play(position, opts), to: Sets
  defdelegate format_to_play(position), to: Sets

  @impl true
  def mount(%{"id" => cycle_id}, _session, socket) do
    round_id = Cycles.current_round_for_cycle(cycle_id).id
    drill = Cycles.next_drill(round_id)

    {:ok,
     assign(socket,
       drill: drill,
       round_id: round_id,
       fen: drill.position.fen,
       duration: nil,
       answer: nil,
       status: nil
     )}
  end

  @impl true
  def handle_event("save_answer", _, %{assigns: assigns} = socket) do
    # drill_params = %{
    #   answer: assigns[:answer],
    #   duration: assigns[:duration]
    # }

    case Cycles.complete_drill(assigns[:drill]) do
      {:next_drill, drill} ->
        {:noreply, assign(socket, drill: drill, status: nil)}

      _ ->
        socket =
          socket
          |> put_flash(:info, "Round completed!")
          |> redirect(to: Routes.cycle_path(socket, :index))

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "board_update",
        %{"pgn" => pgn, "fen" => fen, "duration" => duration},
        %{assigns: %{drill: drill}} = socket
      ) do
    case Drills.evaluate_moves(drill.position.solution_moves, PGN.new(pgn).moves) do
      {:correct, moves} ->
        # rerender so that next move can be played
        {:noreply, assign(socket, %{answer: moves, fen: fen, duration: duration})}

      {:full_match, moves} ->
        # move is correct AND drill is complete
        # Show correct in view and next drill button
        # Stop timer
        {:noreply, assign(socket, %{answer: moves, fen: fen, duration: duration})}

      {:incorrect, moves} ->
        drill = Drills.create_drill(drill, %{answer: moves, duration: duration})

        socket =
          socket
          |> assign(%{
            drill: drill,
            answer: moves,
            fen: fen,
            duration: duration,
            status: :incorrect
          })
          |> push_event("stop_drill", %{status: :incorrect})

        {:noreply, socket}
    end
  end
end
