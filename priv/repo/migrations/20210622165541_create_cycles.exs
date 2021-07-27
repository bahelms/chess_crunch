defmodule ChessCrunch.Repo.Migrations.CreateCycles do
  use Ecto.Migration

  def change do
    create table(:cycles) do
      add :name, :text, null: false
      add :completed_on, :utc_datetime
      add :time_limit, :integer, null: false
      add :user_id, references("users", type: :binary_id)

      timestamps()
    end

    create index(:cycles, [:user_id])
  end
end
