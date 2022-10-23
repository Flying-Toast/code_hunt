defmodule CodeHunt.Repo.Migrations.MissionNames do
  use Ecto.Migration

  def change do
    alter table(:missions) do
      add :name, :string, null: false, default: ""
    end
  end
end
