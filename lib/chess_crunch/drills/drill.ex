defmodule ChessCrunch.Drills.Drill do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "drills" do
    field :fen, :string
    field :solution, :string
    field :to_play, :string
    field :image_id, :string
    belongs_to(:set, ChessCrunch.Sets.Set)

    timestamps()
  end

  @doc false
  def changeset(drill, attrs) do
    drill
    |> generate_image_id()
    |> cast(attrs, [:fen, :solution, :to_play, :image_id, :set_id])
    |> validate_required([:to_play, :set_id])
  end

  defp generate_image_id(drill) do
    Map.put(drill, :image_id, Ecto.UUID.generate())
  end
end
