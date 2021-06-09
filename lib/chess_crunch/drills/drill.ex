defmodule ChessCrunch.Drills.Drill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drills" do
    field :fen, :string
    field :solution, :string
    field :to_play, :string

    timestamps()
  end

  @doc false
  def changeset(drill, attrs) do
    drill
    |> cast(attrs, [:fen, :solution, :to_play])
    |> validate_required([:fen, :solution, :to_play])
  end
end
