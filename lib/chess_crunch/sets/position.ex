defmodule ChessCrunch.Sets.Position do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "positions" do
    field :fen, :string
    field :solution, :string
    field :to_play, :string
    field :image_id, :string
    field :name, :string
    belongs_to(:set, ChessCrunch.Sets.Set)

    timestamps()
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> generate_image_id()
    |> cast(attrs, [:fen, :solution, :to_play, :image_id, :set_id, :name])
    |> validate_required([:to_play, :set_id, :name])
  end

  defp generate_image_id(position) do
    Map.put(position, :image_id, Ecto.UUID.generate())
  end
end
