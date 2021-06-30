defmodule ChessCrunch.Cycles do
  @moduledoc """
  The Cycles context.
  """

  import Ecto.Query, warn: false
  alias ChessCrunch.Repo
  alias ChessCrunch.{Sets, Cycles.Cycle}

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
end
