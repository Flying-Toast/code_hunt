defmodule CodeHunt.Hunting.CodeDrop do
  use Ecto.Schema
  import Ecto.Changeset

  schema "code_drops" do
    field :claimed_by, :string, size: 10
    field :claim_date, :utc_datetime
    field :secret_id, :binary, null: false, size: 33

    timestamps()
  end

  @doc false
  def changeset(code_drop, attrs) do
    code_drop
    |> cast(attrs, [:claimed_by, :claim_date, :secret_id])
    |> validate_required([:secret_id])
  end
end
