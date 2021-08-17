defmodule ChessCrunchWeb.CycleView do
  use ChessCrunchWeb, :view
  alias ChessCrunch.Cycles
  alias ChessCrunch.Cycles.Cycle

  def set_options(sets), do: Enum.map(sets, &[key: &1.name, value: &1.id])

  def status(_, %Cycle{completed_on: completed_on}) when completed_on, do: "Completed"

  def status(round) do
    if Cycles.needs_solutions?(round) do
      "Needs Solutions"
    end
  end

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

  def card_color(cycle) do
    if Cycles.needs_solutions?(cycle) do
      "red"
    end
  end
end
