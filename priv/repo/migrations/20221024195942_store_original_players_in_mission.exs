defmodule CodeHunt.Repo.Migrations.StoreOriginalPlayersInMission do
  use Ecto.Migration

  def change do
    alter table(:missions) do
      add :original_caseids, {:array, :string}, null: false, default: []
    end
  end
end
