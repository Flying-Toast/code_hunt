defmodule CodeHunt.Repo.Migrations.Comments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :author_id, references(:players, on_delete: :delete_all)
      add :receiver_id, references(:players, on_delete: :delete_all)
      add :body, :string, null: false
      add :accepted, :boolean, null: false, default: false

      timestamps(type: :utc_datetime)
    end
  end
end
