defmodule CodeHuntWeb.PageController do
  use CodeHuntWeb, :controller
  alias CodeHunt.Contest

  def index(conn, _params) do
    num_claimed = Contest.player_score(conn.assigns.me_player)
    remaining_quota = max(100 - num_claimed, 0)
    render(conn, "index.html", num_claimed: num_claimed, remaining_quota: remaining_quota)
  end

  def login_prompt(conn, _params) do
    if conn.assigns.me_player do
      redirect(conn, to: Routes.page_path(conn, :index))
    else
      render(conn, "login_prompt.html")
    end
  end
end
