defmodule ChessCrunch.Cycles.Drill do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "drills" do
    field :answer, :string
    # in seconds
    field :duration, :integer
    field :completed_on, :utc_datetime
    belongs_to :cycle, ChessCrunch.Cycles.Cycle
    belongs_to :position, ChessCrunch.Sets.Position, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(drill, attrs) do
    drill
    |> cast(attrs, [:cycle_id, :position_id, :answer, :duration, :completed_on])
    |> validate_required([:cycle_id, :position_id])
  end
end
