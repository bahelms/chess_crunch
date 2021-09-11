defmodule ChessCrunchWeb.CycleLive do
  use ChessCrunchWeb, :live_view
  alias ChessCrunch.{PGN, Cycles, Drills, Sets}

  defdelegate format_to_play(position, opts), to: Sets
  defdelegate format_to_play(position), to: Sets

  defp initial_state(drill), do: [drill: drill, fen: drill.position.fen, status: nil]

  defp initial_state(drill, time_limit),
    do: Keyword.merge(initial_state(drill), time_limit: time_limit)

  @impl true
  def mount(%{"id" => cycle_id}, _session, socket) do
    round = Cycles.current_round_for_cycle(cycle_id)
    drill = Cycles.next_drill(round.id)
    {:ok, assign(socket, initial_state(drill, round.time_limit))}
  end

  @impl true
  def handle_event(
        "board_update",
        %{"pgn" => pgn, "fen" => fen, "duration" => duration},
        %{assigns: %{drill: drill}} = socket
      ) do
    case Drills.evaluate_moves(drill.position.solution_moves, PGN.new(pgn).moves) do
      {:correct, moves} ->
        {:noreply, assign(socket, %{fen: fen, moves: moves})}

      {:full_match, moves} ->
        drill = Drills.create_drill(drill, %{answer: moves, duration: duration})
        {:noreply, stop_drill(socket, drill, fen, :completed)}

      {:incorrect, moves} ->
        drill = Drills.create_drill(drill, %{answer: moves, duration: duration})
        {:noreply, stop_drill(socket, drill, fen, :incorrect)}
    end
  end

  @impl true
  def handle_event("next_drill", _, %{assigns: assigns} = socket) do
    case Cycles.complete_drill(assigns[:drill]) do
      {:next_drill, drill} ->
        {:noreply, new_drill(socket, drill)}

      _ ->
        # TODO: show that the round needs to be repeated due to low accuracy
        socket =
          socket
          |> put_flash(:info, "Round completed!")
          |> redirect(to: Routes.cycle_path(socket, :index))

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("store_moves", %{"pgn" => pgn, "duration" => duration}, socket) do
    {:noreply, assign(socket, %{moves: PGN.new(pgn).moves, duration: duration})}
  end

  @impl true
  def handle_event("save_answer", _, %{assigns: assigns} = socket) do
    %{drill: drill, moves: moves, duration: duration} = assigns
    drill = Drills.create_drill(drill, %{answer: moves, duration: duration})

    case Cycles.complete_drill(drill) do
      {:next_drill, drill} ->
        {:noreply, new_drill(socket, drill)}

      _ ->
        # TODO: show that the round needs to be repeated due to low accuracy
        socket =
          socket
          |> put_flash(:info, "Round completed!")
          |> redirect(to: Routes.cycle_path(socket, :index))

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "timed_out",
        %{"fen" => fen, "duration" => duration},
        %{assigns: %{drill: drill}} = socket
      ) do
    moves = socket.assigns[:moves]
    drill = Drills.create_drill(drill, %{answer: moves, duration: duration})
    {:noreply, assign(socket, %{drill: drill, fen: fen, status: :incorrect})}
  end

  defp stop_drill(socket, drill, fen, status) do
    socket
    |> assign(%{drill: drill, fen: fen, status: status})
    |> push_event("stop_drill", %{})
  end

  defp new_drill(socket, drill) do
    socket
    |> assign(initial_state(drill))
    |> push_event("new_game", %{fen: drill.position.fen})
  end
end
