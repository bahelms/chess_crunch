defmodule ChessCrunch.Sets.Set do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sets" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
