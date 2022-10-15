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

  def track_new_message(caseid, new_message) do
    create_event(%{kind: :message_changed, caseid: caseid, msg: new_message})
  end

  def track_leaderboard_view(caseid) do
    if !Repo.exists?(from e in Event, where: e.event["kind"] == "seen_leaderboard") do
      create_event(%{kind: :seen_leaderboard, caseid: caseid})
    end
  end

  def track_page_view(caseid, url) do
    create_event(%{kind: :page_view, caseid: caseid, url: url})
  end

  defp create_event(event) do
    event.kind

    %Event{}
    |> Event.changeset(%{event: event})
    |> Repo.insert()
  end
end
