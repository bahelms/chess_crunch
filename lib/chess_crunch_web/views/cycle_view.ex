defmodule ChessCrunchWeb.CycleView do
  use ChessCrunchWeb, :view
  alias ChessCrunch.Cycles.Cycle

  def set_options(sets), do: Enum.map(sets, &[key: &1.name, value: &1.id])

  def status(%Cycle{completed_on: nil}), do: "In Progress"
  def status(_), do: "Completed"

  def drills_completed(cycle) do
    "22/36"
  end
end
