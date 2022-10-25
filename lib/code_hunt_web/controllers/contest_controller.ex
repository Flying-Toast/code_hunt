defmodule CodeHuntWeb.ContestController do
  use CodeHuntWeb, :controller
  alias CodeHunt.Contest

  def leaderboard(conn, _params) do
    leaders = Contest.get_leaders(10)
    CodeHunt.Telemetry.track_leaderboard_view(conn.assigns.me_player.caseid)
    render(conn, "leaderboard.html", leaders: leaders, link_to_full_leaderboard: true)
  end

  def full_leaderboard(conn, _params) do
    leaders = Contest.get_leaders(true)
    render(conn, "leaderboard.html", leaders: leaders, link_to_full_leaderboard: false)
  end

  def show_players(conn, _params) do
    players = Contest.list_players()

    render(conn, "show_players.html", players: players)
  end

  def msg(conn, %{"caseid" => caseid}) do
    player = Contest.get_player_by_caseid!(caseid)
    if player.banned do
      conn
      |> put_status(404)
      |> put_root_layout(false)
      |> put_view(CodeHuntWeb.ErrorView)
      |> render("404.html")
      |> halt()
    else
      show_form = conn.assigns.me_player.caseid == caseid
      earliest_claim = Contest.time_of_first_claim_or_nil(player)

      render(conn, "player_page.html", player: player, show_form: show_form, earliest_claim_or_nil: earliest_claim)
    end
  end

  def update_message(conn, %{"new_message" => new_message}) do
    if new_message != conn.assigns.me_player.msg do
      Contest.set_player_message(conn.assigns.me_player.caseid, new_message)
      CodeHunt.Telemetry.track_new_message(conn.assigns.me_player.caseid, new_message)
    end

    redirect(conn, to: Routes.contest_path(conn, :msg, conn.assigns.me_player.caseid))
  end
end
