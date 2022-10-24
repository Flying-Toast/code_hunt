defmodule CodeHunt.Missions.Trophy do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.{Contest, Missions}

  schema "trophies" do
    belongs_to :mission, Missions.Mission
    belongs_to :player, Contest.Player

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(trophy, attrs) do
    trophy
    |> cast(attrs, [:mission_id, :player_id])
    |> validate_required([:mission_id, :player_id])
  end
end
