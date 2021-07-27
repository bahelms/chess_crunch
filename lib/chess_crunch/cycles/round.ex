defmodule ChessCrunch.Cycles.Round do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rounds" do
    field :number, :integer
    field :completed_on, :utc_datetime
    timestamps()

    has_many :drills, ChessCrunch.Cycles.Drill
    belongs_to :cycle, ChessCrunch.Cycles.Cycle
  end

  @doc false
  def changeset(drill, attrs) do
    drill
    |> cast(attrs, [:cycle_id, :number, :completed_on])
    |> validate_required([:number])
  end
end
