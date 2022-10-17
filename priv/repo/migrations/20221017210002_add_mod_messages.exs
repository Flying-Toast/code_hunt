defmodule CodeHunt.Repo.Migrations.AddModMessages do
  use Ecto.Migration

  def change do
    create table(:mod_messages) do
      add :message, :string, null: false
      add :player_id, references(:players)

      timestamps(type: :utc_datetime)
    end
  end
end
