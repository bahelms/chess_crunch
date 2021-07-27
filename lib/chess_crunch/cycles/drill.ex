defmodule ChessCrunch.Cycles.Drill do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "drills" do
    field :answer, :string
    # in seconds
    field :duration, :integer
    belongs_to :round, ChessCrunch.Cycles.Round
    belongs_to :position, ChessCrunch.Sets.Position, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(drill, attrs) do
    drill
    |> cast(attrs, [:round_id, :position_id, :answer, :duration])
    |> validate_required([:round_id, :position_id])
  end
end
