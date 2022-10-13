defmodule CodeHunt.Repo.Migrations.UserMessages do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :msg, :string, default: ""
    end
  end
end
