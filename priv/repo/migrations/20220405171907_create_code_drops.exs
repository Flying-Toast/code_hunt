defmodule CodeHunt.Repo.Migrations.CreateCodeDrops do
  use Ecto.Migration

  def change do
    create table(:code_drops) do
      add :claimed_by, :string, size: 10
      add :claim_date, :utc_datetime
      add :secret_id, :binary, null: false, size: 33

      timestamps(type: :utc_datetime)
    end
  end
end
