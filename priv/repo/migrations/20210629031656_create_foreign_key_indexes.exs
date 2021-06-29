defmodule ChessCrunch.Repo.Migrations.CreateForeignKeyIndexes do
  use Ecto.Migration

  def change do
    create index(:positions, [:set_id])
    create index(:sets, [:user_id])
    create index(:cycles, [:user_id])
  end
end
