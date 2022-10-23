defmodule CodeHunt.Contest.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.{Hunting, Site, Missions}

  schema "players" do
    field :caseid, :string
    field :banned, :boolean, default: false
    field :ban_reason, :string, default: ""
    field :msg, :string, default: ""
    has_many :code_drops, Hunting.CodeDrop
    has_many :mod_messages, Site.ModMessage
    belongs_to :mission, Missions.Mission

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:caseid, :banned, :msg, :ban_reason, :mission_id])
    |> validate_required([:caseid])
    |> validate_length(:msg, max: 300)
  end
end
