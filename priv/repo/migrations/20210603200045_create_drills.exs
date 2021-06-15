defmodule ChessCrunch.Repo.Migrations.CreateDrills do
  use Ecto.Migration

  def change do
    create table(:drills, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text, null: false
      add :to_play, :string, null: false
      add :fen, :text
      add :solution, :text
      add :image_id, :text
      add :details, :text
      add :set_id, references(:sets)
      timestamps()
    end
  end
end
