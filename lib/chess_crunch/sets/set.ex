defmodule ChessCrunch.Sets.Set do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sets" do
    field :name, :string
    belongs_to(:user, ChessCrunch.Accounts.User, type: :binary_id)

    timestamps()
  end

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
