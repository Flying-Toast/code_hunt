defmodule CodeHuntWeb.ContestController do
  use CodeHuntWeb, :controller
  alias CodeHunt.Contest

  def leaderboard(conn, _params) do
    leaders = Contest.get_leaders(10)
    render(conn, "leaderboard.html", leaders: leaders)
  end

  def show_players(conn, _params) do
    players = Contest.list_players()

    render(conn, "show_players.html", players: players)
  end
end
