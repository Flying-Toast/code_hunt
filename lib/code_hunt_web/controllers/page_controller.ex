defmodule CodeHuntWeb.PageController do
  use CodeHuntWeb, :controller
  alias CodeHunt.{Contest, Site, Missions}

  def tbc(conn, _params) do
    render(conn, "tbc.html")
  end

  def index(conn, _params) do
    if conn.assigns.me_player.banned do
      ban_reason = conn.assigns.me_player.ban_reason
      render(conn, "banned.html", ban_reason: ban_reason)
    else
      num_claimed = Contest.player_score(conn.assigns.me_player)
      num_trophies = Missions.num_trophies(conn.assigns.me_player)
      remaining_quota = max(Contest.points_needed_for_mission_1() - num_claimed, 0)
      mod_messages = Site.mod_messages_for(conn.assigns.me_player)
      for msg <- mod_messages, do: Site.mod_message_seen(msg)

      render(
        conn,
        "index.html",
        num_claimed: num_claimed,
        num_trophies: num_trophies,
        remaining_quota: remaining_quota,
        mod_messages: mod_messages
      )
    end
  end

  def login_prompt(conn, _params) do
    if conn.assigns.me_player do
      redirect(conn, to: Routes.page_path(conn, :index))
    else
      render(conn, "login_prompt.html")
    end
  end
end
