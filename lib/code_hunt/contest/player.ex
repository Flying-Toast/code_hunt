defmodule CodeHunt.Contest.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.Hunting

  schema "players" do
    field :caseid, :string
    field :banned, :boolean, default: false
    field :msg, :string, default: ""
    has_many :code_drops, Hunting.CodeDrop

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:caseid, :banned, :msg])
    |> validate_required([:caseid])
    |> validate_length(:msg, max: 300)
  end
end
