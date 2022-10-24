defmodule CodeHunt.Repo.Migrations.Trophies do
  use Ecto.Migration

  def change do
    create table(:trophies) do
      add :mission_id, references(:missions, on_delete: :delete_all)
      add :player_id, references(:players, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
