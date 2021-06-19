defmodule ChessCrunch.Drills.Drill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drills" do
    timestamps()
  end

  @doc false
  def changeset(drill, attrs) do
    drill
    |> cast(attrs, [])
  end
end
