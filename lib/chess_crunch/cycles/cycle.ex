defmodule ChessCrunch.Cycles.Cycle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cycles" do
    field :name, :string
    field :completed_on, :utc_datetime

    many_to_many :sets, ChessCrunch.Sets.Set, join_through: "cycles_sets"
    has_many :rounds, ChessCrunch.Cycles.Round
    belongs_to :user, ChessCrunch.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [:completed_on, :name, :user_id])
    |> cast_assoc(:rounds)
    |> validate_required([:user_id, :name])
  end
end
