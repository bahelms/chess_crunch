defmodule ChessCrunch.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets) do
      add :name, :text
      timestamps()
    end
  end
end
