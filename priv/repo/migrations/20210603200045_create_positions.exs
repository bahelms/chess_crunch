defmodule ChessCrunch.Repo.Migrations.CreatePositions do
  use Ecto.Migration

  def change do
    create table(:positions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text, null: false
      add :to_play, :string, null: false
      add :fen, :text
      add :solution_fen, :text
      add :solution_moves, :text
      add :image_filename, :text
      add :details, :text
      add :set_id, references(:sets, on_delete: :nilify_all)
      timestamps()
    end

    create index(:positions, [:set_id])
  end
end
