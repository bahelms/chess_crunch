defmodule ChessCrunch.Drills do
  @moduledoc """
  The Drills context.
  """

  alias ChessCrunch.Cycles.Drill
  alias ChessCrunch.Repo

  def create_drill(attrs) do
    %Drill{}
    |> Drill.changeset(attrs)
    |> Repo.insert!()
  end

  def create_drill(%Drill{} = drill, changes) do
    drill
    |> Drill.changeset(changes)
    |> Repo.insert!()
  end

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

  @doc "Returns average in whole seconds"
  def average_duration([]), do: 0

  def average_duration(drills) do
    sum =
      drills
      |> Enum.map(& &1.duration)
      |> Enum.sum()

    round(sum / length(drills))
  end

  defp subset(solution, moves) do
    solution_moves = String.split(solution)
    answer_moves = String.split(moves)
    Enum.zip(solution_moves, answer_moves)
  end

  def accuracy_percent([]), do: 0

  def accuracy_percent(drills) do
    counts = accuracy_counts(drills)
    counts.correct / length(drills) * 100
  end

  def accuracy_counts([]), do: %{correct: 0, incorrect: 0}

  # TODO: putting result on drill table may optimize this away
  def accuracy_counts(drills) do
    Enum.reduce(drills, accuracy_counts([]), fn drill, counts ->
      if drill.answer == drill.position.solution_moves do
        Map.update!(counts, :correct, &(&1 + 1))
      else
        Map.update!(counts, :incorrect, &(&1 + 1))
      end
    end)
  end
end
