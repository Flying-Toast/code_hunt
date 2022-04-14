defmodule CodeHunt.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :event, :map, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
