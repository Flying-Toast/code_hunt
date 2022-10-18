defmodule CodeHunt.Repo.Migrations.TrackModMessageViews do
  use Ecto.Migration

  def change do
    alter table(:mod_messages) do
      add :seen, :boolean, default: false
    end
  end
end
