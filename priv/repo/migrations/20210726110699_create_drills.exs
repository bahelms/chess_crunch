defmodule ChessCrunch.Repo.Migrations.CreateDrills do
  use Ecto.Migration

  def change do
    create table(:drills, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :answer, :text
      add :duration, :integer
      add :round_id, references(:rounds, on_delete: :delete_all)
      add :position_id, references(:positions, type: :binary_id, on_delete: :delete_all)
      timestamps()
    end

    create index(:drills, [:round_id])
    create index(:drills, [:position_id])
  end
end
