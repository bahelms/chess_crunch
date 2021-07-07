defmodule ChessCrunch.Repo.Migrations.CreateCyclesSetsTable do
  use Ecto.Migration

  def change do
    create table(:cycles_sets, primary_key: false) do
      add :cycle_id, references(:cycles, on_delete: :delete_all)
      add :set_id, references(:sets, on_delete: :delete_all)
    end

    create index(:cycles_sets, [:cycle_id])
  end
end
