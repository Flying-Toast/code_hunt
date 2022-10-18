defmodule CodeHunt.Repo.Migrations.BanReason do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :ban_reason, :string, null: false, default: ""
    end
  end
end
