defmodule CodeHunt.Telemetry do
  import Ecto.Query, warn: false
  alias CodeHunt.Repo
  alias CodeHunt.Telemetry.Event

  def reverse_chronological_events do
    Repo.all(Event)
    |> Enum.reverse()
  end

  def track_user_creation(caseid) do
    create_event(%{kind: :new_user, caseid: caseid})
  end

  def track_rescan(drop, player) do
    create_event(%{kind: :rescan, scanner: player.caseid, owner: drop.player.caseid, drop_id: drop.id})
  end

  def track_good_claim(drop, player) do
    create_event(%{kind: :good_claim, scanner: player.caseid, drop_id: drop.id})
  end

  def track_mission_completion(player, mission_num) do
    create_event(%{kind: :mission_complete, caseid: player.caseid, mission_num: mission_num})
  end

  defp create_event(event) do
    event.kind

    %Event{}
    |> Event.changeset(%{event: event})
    |> Repo.insert()
  end
end
