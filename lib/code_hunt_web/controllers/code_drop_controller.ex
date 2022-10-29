defmodule CodeHuntWeb.CodeDropController do
  use CodeHuntWeb, :controller
  alias CodeHunt.{Hunting, Contest, Telemetry, Missions}

  def claim(conn, %{"secret_id" => secret_id}) do
    drop = Hunting.get_code_drop_by_base64encoded_secret_id(secret_id)

    cond do
      drop == nil ->
        render(conn, "invalid.html")


      drop.player ->
        unless Contest.is_admin(conn.assigns.me_player) do
          Telemetry.track_rescan(drop, conn.assigns.me_player)
        end

        render(conn, "already_claimed.html", drop: drop)


      drop.mission == nil ->
        Telemetry.track_good_claim(drop, conn.assigns.me_player)

        {:ok, _drop} = Hunting.claim_code_drop(drop, conn.assigns.me_player)
        num_claimed = 1 + length(conn.assigns.me_player.code_drops)
        finished_mission_1 = num_claimed == Contest.points_needed_for_mission_1()
        if finished_mission_1 do
          Telemetry.track_mission_completion(conn.assigns.me_player, 1)
          render(conn, "mission_completed.html", mission_num: 1)
        else
          render(conn, "successful_claim.html")
        end


      not Missions.details_released?(drop.mission) ->
        Telemetry.track_early_mission_scan(drop, conn.assigns.me_player)
        render(conn, "early_mission_scan.html")


      not Missions.mission_active?(drop.mission) ->
        Telemetry.track_inactive_mission_scan(drop, conn.assigns.me_player)
        render(conn, "mission_ended.html")


      not Missions.assigned_to_mission?(conn.assigns.me_player, drop.mission) ->
        render(conn, "not_assigned_to_this_mission.html")


      true ->
        Telemetry.track_good_mission_claim(drop, conn.assigns.me_player)
        {:ok, _drop} = Hunting.claim_code_drop(drop, conn.assigns.me_player)
        render(conn, "successful_mission_claim.html", mission: drop.mission)
    end
  end


  def show_drops(conn, _params) do
    drops = Hunting.list_drops()

    render(conn, "show_drops.html", drops: drops)
  end

  def show_code_sheet(conn, %{"id" => id}) do
    sheet = Hunting.get_code_sheet!(id)

    conn
    |> put_root_layout(false)
    |> render("show_sheet.html", drops: sheet.code_drops, is_for_mission: false)
  end
end
