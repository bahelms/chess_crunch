defmodule ChessCrunchWeb.CycleLive do
  use ChessCrunchWeb, :live_view
  alias ChessCrunch.Cycles

  @impl true
  def mount(%{"id" => cycle_id}, _session, socket) do
    round_id = Cycles.current_round_for_cycle(cycle_id).id

    {:ok,
     assign(socket,
       drill: Cycles.next_drill(round_id),
       round_id: round_id,
       answer: nil,
       duration: nil
     )}
  end

  @impl true
  def handle_event("save_answer", _, %{assigns: assigns} = socket) do
    drill_params = %{
      answer: assigns[:answer],
      duration: assigns[:duration]
    }

    # TODO: refactor not to need cycle_id
    case Cycles.complete_drill(assigns[:drill], drill_params, assigns[:round_id]) do
      {:round_completed, _, _} ->
        socket =
          socket
          |> put_flash(:info, "Round completed!")
          |> redirect(to: Routes.cycle_path(socket, :index))

        {:noreply, socket}

      {:next_drill, drill} ->
        {:noreply, assign(socket, drill: drill)}
    end
  end

  @impl true
  def handle_event(
        "board_update",
        %{"pgn" => pgn, "duration" => duration},
        %{assigns: _assigns} = socket
      ) do
    moves =
      pgn
      |> String.split("\n\n")
      |> List.last()

    # if assigns[:drill].position.solution do
    #   # check if moves are correct
    #   #   If incorrect, save answer and end drill
    # end

    {:noreply, assign(socket, %{answer: moves, duration: duration})}
  end

  defp format_to_play(%{to_play: "w"}), do: "White"
  defp format_to_play(_), do: "Black"
end
