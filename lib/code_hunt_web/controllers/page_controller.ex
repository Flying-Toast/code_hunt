defmodule CodeHuntWeb.PageController do
  use CodeHuntWeb, :controller
  alias CodeHunt.Hunting

  def index(conn, _params) do
    num_claimed = Hunting.claimed_codes_count(conn.assigns.caseid)
    remaining_quota = max(100 - num_claimed, 0)
    render(conn, "index.html", num_claimed: num_claimed, remaining_quota: remaining_quota)
  end

  def login_prompt(conn, _params) do
    render(conn, "login_prompt.html")
  end
end
