defmodule CodeHuntWeb.MissionController do
  require EEx
  use CodeHuntWeb, :controller
  alias CodeHunt.{Missions, Contest, Hunting, Telemetry}

  def show_missions(conn, _params) do
    missions = Missions.list_missions()
    render(conn, "show_missions.html", missions: missions)
  end

  def show_mission(conn, %{"id" => id}) do
    mission = Missions.get_mission(id)
    num_unclaimed = Missions.unscanned_tokens_remaining(mission)
    render(conn, "show_mission.html", mission: mission, unscanned_count: num_unclaimed)
  end

  def show_declassified_mission(conn, %{"id" => id}) do
    mission = Missions.get_mission(id)
    if Missions.mission_active?(mission) do
      # dont reveal in-progress missions
      conn
      |> put_status(404)
      |> put_root_layout(false)
      |> put_view(CodeHuntWeb.ErrorView)
      |> render("404.html")
      |> halt()
    else
      participating_caseids = Missions.caseids_who_participated_in_mission(mission)
      render(conn, "show_declassified_mission.html", mission: mission, participating_caseids: participating_caseids)
    end
  end

  def new_mission_form(conn, _params) do
    render(conn, "mission_form.html")
  end

  def create_mission(conn, %{"player_caseids" => player_caseids, "mission_name" => mission_name, "num_drops" => num_drops, "details" => details, "release_in_minutes" => release_in_minutes, "duration_hours" => duration_hours}) do
    player_caseids = player_caseids
                     |> String.split()
                     |> Enum.uniq()
    players = Enum.map(player_caseids, &Contest.get_player_by_caseid!/1)

    num_drops = String.to_integer(num_drops)
    release_in_minutes = String.to_integer(release_in_minutes)
    release_time = DateTime.utc_now()
                   |> DateTime.add(release_in_minutes, :minute)
    duration_hours = String.to_integer(duration_hours)
    end_date = release_time |> DateTime.add(duration_hours, :hour)

    caseids_in_mission = Enum.filter(players, fn p -> Missions.mission_active?(p.mission) end)
                         |> Enum.map(& &1.caseid)

    caseids_in_onboarding = Enum.filter(players, fn p -> length(p.code_drops) < Contest.points_needed_for_mission_1() end)
                            |> Enum.map(& &1.caseid)

    cond do
      length(caseids_in_mission) != 0 ->
        text(conn, "Some players are already in another mission:\n#{Enum.join(caseids_in_mission, "\n")}")

      length(caseids_in_onboarding) != 0 ->
        text(conn, "Some players still in onboarding:\n#{Enum.join(caseids_in_onboarding, "\n")}")

      true ->
        {:ok, mission} = Missions.create_mission(mission_name, details, release_time, end_date, player_caseids)
        for _ <- 1..num_drops do
          Hunting.create_code_drop(%{mission_id: mission.id})
        end

        _players = Enum.map(
          players,
          &Contest.update_player(&1, %{mission_id: mission.id})
        )

        redirect(conn, to: Routes.mission_path(conn, :show_mission, mission.id))
    end
  end

  def show_objective(conn, _params) do
    if Missions.mission_active?(conn.assigns.me_player.mission) do
      mission = CodeHunt.Repo.preload(conn.assigns.me_player.mission, [:drops])
      num_unscanned = Missions.unscanned_tokens_remaining(mission)
      if :lt == DateTime.compare(DateTime.utc_now(), mission.details_release_date) do
        Telemetry.track_objective_view_before_mission_start(conn.assigns.me_player, mission)
      end
      render(conn, "objective.html", mission: mission, remaining_unscanned_count: num_unscanned)
    else
      render(conn, "not_in_mission.html")
    end
  end

  def show_mission_drops(conn, %{"mission_id" => mission_id}) do
    conn
    |> put_root_layout(false)
    |> put_view(CodeHuntWeb.CodeDropView)
    |> render("show_sheet.html", drops: Missions.get_mission(mission_id).drops, is_for_mission: true, sheet_id: "M#{mission_id}")
  end

  def calling_cards(conn, %{"mission_id" => id}) do
    mission = Missions.get_mission(id)

    conn
    |> put_root_layout(false)
    |> render("calling_cards.html", caseids: mission.original_caseids)
  end
end
