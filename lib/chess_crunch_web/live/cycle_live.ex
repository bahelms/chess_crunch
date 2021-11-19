defmodule ChessCrunchWeb.CycleLive do
  use ChessCrunchWeb, :live_view
  alias ChessCrunch.{PGN, Cycles, Drills, Sets, Timer}
  alias ChessCrunchWeb.ChessBoardComponent

  defdelegate format_to_play(position, opts), to: Sets
  defdelegate format_to_play(position), to: Sets

  defp initial_state(drill),
    do: [
      drill: drill,
      fen: drill.position.fen,
      status: nil,
      drill_time: "00:00",
      drill_active: true,
      moves: ""
    ]

  defp initial_state(drill, time_limit, timer),
    do: Keyword.merge(initial_state(drill), time_limit: time_limit, timer: timer)

  @impl true
  def mount(%{"id" => cycle_id}, _session, socket) do
    round = Cycles.current_round_for_cycle(cycle_id)
    drill = Cycles.next_drill(round.id)
    {:ok, timer} = Timer.start_link(self())

    if connected?(socket) do
      Timer.start(timer)
    end

    {:ok, assign(socket, initial_state(drill, round.time_limit, timer))}
  end

  @impl true
  def handle_event(
        "board_update",
        %{"pgn" => pgn, "fen" => fen},
        %{assigns: %{drill: drill, timer: timer}} = socket
      ) do
    case Drills.evaluate_moves(drill.position.solution_moves, PGN.new(pgn).moves) do
      {:correct, moves} ->
        {:noreply, assign(socket, %{fen: fen, moves: moves})}

      {:full_match, moves} ->
        duration = Timer.stop(timer)
        drill = Drills.persist_drill(drill, %{answer: moves, duration: duration})
        Cycles.complete_drill(drill)
        {:noreply, stop_drill(socket, drill, fen, :completed)}

      {:incorrect, moves} ->
        duration = Timer.stop(timer)
        drill = Drills.persist_drill(drill, %{answer: moves, duration: duration})
        Cycles.complete_drill(drill)
        {:noreply, stop_drill(socket, drill, fen, :incorrect)}
    end
  end

  @impl true
  def handle_event("next_drill", _, %{assigns: assigns} = socket) do
    case Cycles.next_drill(assigns.drill.round_id) do
      nil ->
        # TODO: show that the round needs to be repeated due to low accuracy
        socket =
          socket
          |> put_flash(:info, "Round completed!")
          |> redirect(to: Routes.cycle_path(socket, :index))

        {:noreply, socket}

      drill ->
        Timer.start(assigns.timer)
        {:noreply, new_drill(socket, drill)}
    end
  end

  @impl true
  def handle_event("store_moves", %{"pgn" => pgn}, socket) do
    {:noreply, assign(socket, %{moves: PGN.new(pgn).moves})}
  end

  @impl true
  def handle_event("save_answer", _, %{assigns: assigns} = socket) do
    %{drill: drill, moves: moves, timer: timer} = assigns
    drill = Drills.persist_drill(drill, %{answer: moves, duration: Timer.elapsed_seconds(timer)})

    case Cycles.complete_drill(drill) do
      {:next_drill, drill} ->
        {:noreply, new_drill(socket, drill)}

      _ ->
        socket =
          socket
          |> put_flash(:info, "Round completed!")
          |> redirect(to: Routes.cycle_path(socket, :index))

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:elapsed_seconds, seconds}, %{assigns: assigns} = socket) do
    if seconds < assigns.time_limit do
      {:noreply, assign(socket, %{drill_time: secs_to_time(seconds)})}
    else
      Timer.stop(assigns.timer)
      state = time_out_drill(assigns.drill, assigns.moves, seconds)
      {:noreply, assign(socket, state)}
    end
  end

  defp time_out_drill(drill, moves, duration) do
    drill =
      Drills.persist_drill(drill, %{
        answer: moves,
        duration: duration
      })

    Cycles.complete_drill(drill)

    %{
      drill: drill,
      status: :incorrect,
      drill_active: false,
      elapsed_seconds: duration,
      drill_time: secs_to_time(duration)
    }
  end

  defp stop_drill(socket, drill, fen, status) do
    socket
    |> assign(%{drill: drill, fen: fen, status: status, drill_active: false})
  end

  defp new_drill(socket, drill) do
    socket
    |> assign(initial_state(drill))
    |> push_event("new_game", %{fen: drill.position.fen})
  end

  defp secs_to_time(secs) do
    mins = format_string(div(secs, 60))
    remaining_secs = format_string(rem(secs, 60))
    "#{mins}:#{remaining_secs}"
  end

  defp format_string(integer) do
    integer
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
