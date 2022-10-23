defmodule CodeHunt.Repo.Migrations.MissionDetails do
  use Ecto.Migration

  def change do
    alter table(:missions) do
      add :details_release_date, :utc_datetime, null: false, default: ""
      add :details, :string, null: false, default: ""
    end
  end
end
