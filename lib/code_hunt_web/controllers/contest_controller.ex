defmodule CodeHuntWeb.ContestController do
  use CodeHuntWeb, :controller
  alias CodeHunt.Contest

  def leaderboard(conn, _params) do
    leaders = Contest.get_leaders(10)
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
    player = Contest.get_player_by_caseid(caseid)

    render(conn, "player_message.html", player: player, show_form: conn.assigns.me_player.caseid == caseid)
  end

  def update_message(conn, %{"new_message" => new_message}) do
    Contest.set_player_message(conn.assigns.me_player.caseid, new_message)

    redirect(conn, to: Routes.contest_path(conn, :msg, conn.assigns.me_player.caseid))
  end
end
