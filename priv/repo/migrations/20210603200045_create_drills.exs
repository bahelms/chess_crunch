defmodule ChessCrunch.Repo.Migrations.CreateDrills do
  use Ecto.Migration

  def change do
    create table(:drills) do
      add :fen, :text
      add :solution, :text
      add :to_play, :string
      add :position_image_id, :text
      add :set_id, references(:sets)
      timestamps()
    end
  end
end
