defmodule ChessCrunchWeb.CycleLive do
  use ChessCrunchWeb, :live_view
  alias ChessCrunch.{PGN, Cycles, Drills}

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
    drill_params = %{
      answer: assigns[:answer],
      duration: assigns[:duration]
    }

    # TODO: refactor not to need round_id
    case Cycles.complete_drill(assigns[:drill], drill_params, assigns[:round_id]) do
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
        socket =
          socket
          |> assign(%{answer: moves, fen: fen, duration: duration, status: :incorrect})
          |> push_event("stop_drill", %{status: :incorrect})

        {:noreply,
         assign(socket, %{answer: moves, fen: fen, duration: duration, status: :incorrect})}
    end
  end

  defp format_to_play(%{to_play: "w"}, caps: false), do: "white"
  defp format_to_play(_, caps: false), do: "black"
  defp format_to_play(%{to_play: "w"}), do: "White"
  defp format_to_play(_), do: "Black"
end
