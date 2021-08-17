defmodule ChessCrunch.Drills do
  @moduledoc """
  The Drills context.
  """

  def evaluate_moves(nil, moves), do: {:correct, moves}

  def evaluate_moves(solution, moves) do
    cond do
      solution == moves ->
        {:full_match, moves}

      Enum.all?(subset(solution, moves), fn {a, b} -> a == b end) ->
        {:correct, moves}

      true ->
        {:incorrect, moves}
    end
  end

  defp subset(solution, moves) do
    solution_moves = String.split(solution)
    answer_moves = String.split(moves)
    Enum.zip(solution_moves, answer_moves)
  end
end
