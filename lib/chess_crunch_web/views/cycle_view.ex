defmodule ChessCrunchWeb.CycleView do
  use ChessCrunchWeb, :view
  alias ChessCrunch.Cycles
  alias ChessCrunch.Cycles.Cycle

  def set_options(sets), do: Enum.map(sets, &[key: &1.name, value: &1.id])

  def status(%Cycle{completed_on: nil}), do: "In Progress"
  def status(_), do: "Completed"

  def drills_completed(cycle) do
    "#{Cycles.total_completed_drills(cycle)}/#{Cycles.positions_in_cycle(cycle)}"
  end

  def format_time_limit(360), do: "6 min"
  def format_time_limit(180), do: "3 min"
  def format_time_limit(90), do: "1.5 min"
  def format_time_limit(45), do: "45 secs"
  def format_time_limit(25), do: "25 secs"
  def format_time_limit(15), do: "15 secs"
  def format_time_limit(10), do: "10 secs"
end
