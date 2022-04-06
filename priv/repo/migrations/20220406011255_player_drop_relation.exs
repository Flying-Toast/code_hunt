defmodule CodeHunt.Repo.Migrations.PlayerDropRelation do
  use Ecto.Migration

  def change do
    alter table(:code_drops) do
      remove :claimed_by
      add :player_id, references(:players)
    end
  end
end
