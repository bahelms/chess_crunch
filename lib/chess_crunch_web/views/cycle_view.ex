defmodule ChessCrunchWeb.CycleView do
  use ChessCrunchWeb, :view
  alias ChessCrunch.{Cycles, Drills}
  alias ChessCrunch.Cycles.Cycle

  def set_options(sets), do: Enum.map(sets, &[key: &1.name, value: &1.id])

  def status(_, %Cycle{completed_on: completed_on}) when completed_on, do: "Completed"

  def status(round) do
    if Cycles.needs_solutions?(round) do
      "Needs Solutions"
    end
  end

  def round_status(%{completed_on: nil}), do: "In Progress"

  def round_status(%{completed_on: date} = round) do
    case Cycles.needs_solutions?(round) do
      true ->
        "Needs Solutions"

      _ ->
        "#{date.month}/#{date.day}/#{date.year}"
    end
  end

  def status_color(%{completed_on: nil}), do: "red"
  def status_color(%{completed_on: _}), do: "black"

  def drills_completed(round) do
    "#{Cycles.total_drills(round)}/#{Cycles.total_positions(round.cycle)}"
  end

  def format_time_limit(360), do: "6 min"
  def format_time_limit(180), do: "3 min"
  def format_time_limit(90), do: "1.5 min"
  def format_time_limit(45), do: "45 secs"
  def format_time_limit(25), do: "25 secs"
  def format_time_limit(15), do: "15 secs"
  def format_time_limit(10), do: "10 secs"

  def average_duration(drills) do
    seconds = Drills.average_duration(drills)

    remaining_seconds =
      seconds
      |> rem(60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{div(seconds, 60)}:#{remaining_seconds}"
  end

  def accuracy_percent(round) do
    case Cycles.needs_solutions?(round) do
      true ->
        "N/A"

      _ ->
        percent = round(Drills.accuracy_percent(round.drills))
        "#{percent}%"
    end
  end

  def accuracy_counts(round) do
    if !Cycles.needs_solutions?(round) do
      counts = Drills.accuracy_counts(round.drills)
      "Correct: #{counts.correct} - Incorrect: #{counts.incorrect}"
    end
  end

  def accuracy_color(round) do
    threshold = Cycles.accuracy_threshold()

    case Drills.accuracy_percent(round.drills) do
      percent when percent < threshold -> "red"
      _ -> "green"
    end
  end
end
