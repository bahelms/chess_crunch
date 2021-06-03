defmodule ChessCrunch.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets) do
      add :name, :text
      add :user_id, references("users", type: :binary_id)
      timestamps()
    end
  end
end
