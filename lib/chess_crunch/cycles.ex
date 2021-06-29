defmodule ChessCrunch.Cycles do
  @moduledoc """
  The Cycles context.
  """

  import Ecto.Query, warn: false
  alias ChessCrunch.Repo
  alias ChessCrunch.Cycles.Cycle

  def list_cycles(user) do
    Cycle
    |> where(user_id: ^user.id)
    |> Repo.all()
  end

  def change_set(%Cycle{} = cycle, attrs \\ %{}) do
    Cycle.changeset(cycle, attrs)
  end

  def create_cycle(attrs \\ %{}) do
    %Cycle{}
    |> Cycle.changeset(attrs)
    |> Repo.insert()
  end

  def get_cycle(id), do: Repo.get!(Cycle, id)
end
