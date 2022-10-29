defmodule CodeHunt.Telemetry do
  import Ecto.Query, warn: false
  alias CodeHunt.Repo
  alias CodeHunt.Telemetry.Event

  def reverse_chronological_events do
    Repo.all(from e in Event, where: e.event["kind"] != "page_view" and e.event["kind"] != "claim_login_redirect" and e.event["kind"] != "claim_sso_redirect")
    |> Enum.reverse()
  end

  def reverse_chronological_requests do
    Repo.all(from e in Event, where: e.event["kind"] == "page_view" or e.event["kind"] == "claim_login_redirect" or e.event["kind"] == "claim_sso_redirect")
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

  def track_good_mission_claim(drop, player) do
    create_event(%{kind: :good_mission_claim, scanner: player.caseid, drop_id: drop.id})
  end

  def track_inactive_mission_scan(drop, player) do
    create_event(%{kind: :inactive_mission_scan, scanner: player.caseid, drop_id: drop.id})
  end

  def track_early_mission_scan(drop, player) do
    create_event(%{kind: :early_mission_scan, scanner: player.caseid, drop_id: drop.id})
  end

  def track_mission_completion(player, mission_num) do
    create_event(%{kind: :mission_complete, caseid: player.caseid, mission_num: mission_num})
  end

  def track_new_message(caseid, new_message) do
    create_event(%{kind: :message_changed, caseid: caseid, msg: new_message})
  end

  def player_has_seen_leaderboard(caseid) do
    Repo.exists?(from e in Event, where: e.event["kind"] == "seen_leaderboard" and e.event["caseid"] == ^caseid)
  end

  def track_leaderboard_view(caseid) do
    if !player_has_seen_leaderboard(caseid) do
      create_event(%{kind: :seen_leaderboard, caseid: caseid})
    end
  end

  def track_page_view(caseid, url) do
    if !CodeHunt.Contest.caseid_is_admin(caseid) do
      create_event(%{kind: :page_view, caseid: caseid, url: url})
    end
  end

  def track_objective_view_before_mission_start(player, mission) do
    event_map = %{kind: :locked_mission_view, caseid: player.caseid, mission_id: mission.id}
    if !Repo.exists?(from e in Event, where: e.event == ^event_map) do
      create_event(event_map)
    end
  end

  def track_claim_login_redirect(url) do
    create_event(%{kind: :claim_login_redirect, url: url})
  end

  def track_claim_sso_redirect(url) do
    create_event(%{kind: :claim_sso_redirect, url: url})
  end

  defp create_event(event) do
    event.kind

    %Event{}
    |> Event.changeset(%{event: event})
    |> Repo.insert()
  end
end
