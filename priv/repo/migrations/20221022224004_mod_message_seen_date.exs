defmodule CodeHunt.Repo.Migrations.ModMessageSeenDate do
  use Ecto.Migration

  def change do
    alter table(:mod_messages) do
      add :seen_date, :utc_datetime, default: nil
    end
  end
end
