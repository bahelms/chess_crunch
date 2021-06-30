defmodule ChessCrunch.Cycles.Cycle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cycles" do
    field :name, :string
    field :completed_on, :utc_datetime
    field :time_limit, :integer
    field :round, :integer
    belongs_to :user, ChessCrunch.Accounts.User, type: :binary_id
    many_to_many :sets, ChessCrunch.Sets.Set, join_through: "cycles_sets"

    timestamps()
  end

  @doc false
  def changeset(cycle, attrs) do
    cycle
    |> cast(attrs, [:completed_on, :name, :time_limit, :round, :user_id])
    |> validate_required([:time_limit, :user_id, :name, :round])
  end
end
