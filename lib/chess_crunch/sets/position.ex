defmodule ChessCrunch.Sets.Position do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "positions" do
    field :fen, :string
    field :solution_moves, :string
    field :solution_fen, :string
    field :to_play, :string
    field :name, :string
    belongs_to(:set, ChessCrunch.Sets.Set)

    timestamps()
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:fen, :solution_moves, :solution_fen, :to_play, :set_id, :name])
    |> validate_required([:to_play, :set_id, :name])
  end
end
