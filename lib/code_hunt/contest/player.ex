defmodule CodeHunt.Contest.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.Hunting

  schema "players" do
    field :caseid, :string, size: 10, null: false
    has_many :code_drops, Hunting.CodeDrop

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:caseid])
    |> validate_required([:caseid])
  end
end
