defmodule CodeHunt.Hunting.CodeDrop do
  use Ecto.Schema
  import Ecto.Changeset

  schema "code_drops" do
    field :claim_date, :utc_datetime
    field :secret_id, :binary, null: false, size: 33
    belongs_to :player, CodeHunt.Contest.Player

    timestamps()
  end

  @doc false
  def changeset(code_drop, attrs) do
    code_drop
    |> cast(attrs, [:claim_date, :secret_id, :player_id])
    |> validate_required([:secret_id])
  end
end
