defmodule ChessCrunch.Cycles do
  @moduledoc """
  The Cycles context.
  """

  import Ecto.Query, warn: false
  alias ChessCrunch.{Repo, Sets}
  alias ChessCrunch.Cycles.{Cycle, Drill}

  def list_cycles(user) do
    Cycle
    |> where(user_id: ^user.id)
    |> Repo.all()
  end

  def change_set(%Cycle{} = cycle, attrs \\ %{}) do
    Cycle.changeset(cycle, attrs)
  end

  def create_cycle(attrs \\ %{}) do
    %Cycle{round: 1}
    |> Cycle.changeset(attrs)
    |> associate_sets(attrs["set_ids"])
    |> Repo.insert()
  end

  def get_cycle(id), do: Repo.get!(Cycle, id)

  defp associate_sets(changeset, set_ids) do
    sets = Sets.find_sets_by_ids(set_ids)
    Ecto.Changeset.put_assoc(changeset, :sets, sets)
  end

  def positions_in_cycle(cycle) do
    cycle
    |> Repo.preload(sets: :positions)
    |> Map.get(:sets)
    |> Enum.reduce(0, fn set, sum -> sum + length(set.positions) end)
  end

  def create_drill(attrs) do
    %Drill{}
    |> Drill.changeset(attrs)
    |> Repo.insert()
  end

  def total_completed_drills(cycle) do
    Repo.preload(cycle, :drills).drills
    |> Enum.filter(&(!is_nil(&1.completed_on)))
    |> length()
  end
end
