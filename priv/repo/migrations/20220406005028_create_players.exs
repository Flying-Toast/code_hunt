defmodule CodeHunt.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :caseid, :string, size: 10, null: false

      timestamps()
    end
  end
end
