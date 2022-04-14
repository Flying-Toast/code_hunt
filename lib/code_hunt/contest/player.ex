defmodule CodeHunt.Contest.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.Hunting

  schema "players" do
    field :caseid, :string, size: 10, null: false
    field :banned, :boolean, default: false
    has_many :code_drops, Hunting.CodeDrop

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:caseid, :banned])
    |> validate_required([:caseid])
  end
end
