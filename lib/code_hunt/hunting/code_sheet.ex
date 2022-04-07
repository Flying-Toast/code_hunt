defmodule CodeHunt.Hunting.CodeSheet do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.Hunting

  schema "code_sheets" do
    has_many :code_drops, Hunting.CodeDrop

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(code_sheet, attrs) do
    code_sheet
    |> cast(attrs, [])
    |> validate_required([])
  end
end
