defmodule ChessCrunchWeb.SetView do
  use ChessCrunchWeb, :view

  def solution_status(nil), do: "Needs Solution"
  def solution_status(_), do: nil
end
