defmodule CodeHunt.Repo.Migrations.BanPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :banned, :boolean, default: false
    end
  end
end
