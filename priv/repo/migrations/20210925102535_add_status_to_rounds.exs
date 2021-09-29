defmodule ChessCrunch.Repo.Migrations.AddStatusToRounds do
  use Ecto.Migration

  def change do
    alter table(:rounds) do
      add :status, :text
    end
  end
end
