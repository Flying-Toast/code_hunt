defmodule CodeHunt.Hunting.CodeDrop do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.{Contest, Hunting}

  schema "code_drops" do
    field :claim_date, :utc_datetime
    field :secret_id, :binary
    belongs_to :player, Contest.Player
    belongs_to :code_sheet, Hunting.CodeSheet

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(code_drop, attrs) do
    code_drop
    |> cast(attrs, [:claim_date, :secret_id, :player_id, :code_sheet_id])
    |> validate_required([:secret_id])
  end
end
