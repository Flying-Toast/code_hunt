defmodule CodeHunt.Repo.Migrations.CreateCodeSheets do
  use Ecto.Migration

  def change do
    create table(:code_sheets) do
      timestamps(type: :utc_datetime)
    end

    alter table(:code_drops) do
      add :code_sheet_id, references(:code_sheets)
    end
  end
end
