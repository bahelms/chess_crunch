defmodule ChessCrunch.Repo.Migrations.CreateDrillsTable do
  use Ecto.Migration

  def change do
    create table(:drills, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :answer, :text
      add :duration, :integer
      add :cycle_id, references(:cycles, on_delete: :delete_all)
      add :position_id, references(:positions, type: :binary_id, on_delete: :delete_all)
      timestamps()
    end

    create index(:drills, [:cycle_id])
    create index(:drills, [:position_id])
  end
end
