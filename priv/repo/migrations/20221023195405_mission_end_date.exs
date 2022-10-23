defmodule CodeHunt.Repo.Migrations.MissionEndDate do
  use Ecto.Migration

  def change do
    alter table(:missions) do
      add :end_date, :utc_datetime, null: false, default: ""
    end
  end
end
