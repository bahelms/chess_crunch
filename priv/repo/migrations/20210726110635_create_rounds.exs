defmodule ChessCrunch.Repo.Migrations.CreateRounds do
  use Ecto.Migration

  def change do
    create table(:rounds) do
      add :number, :integer, null: false
      add :completed_on, :utc_datetime
      add :time_limit, :integer, null: false
      add :cycle_id, references(:cycles, on_delete: :delete_all)
      timestamps()
    end

    create index(:rounds, [:cycle_id])
  end
end
