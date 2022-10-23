defmodule CodeHunt.Repo.Migrations.CreateMissions do
  use Ecto.Migration

  def change do
    create table(:missions) do
      timestamps(type: :utc_datetime)
    end

    alter table(:players) do
      add :mission_id, references(:missions, on_delete: :nilify_all)
    end

    alter table(:code_drops) do
      add :mission_id, references(:missions, on_delete: :delete_all)
    end
  end
end
