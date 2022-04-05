defmodule CodeHuntWeb.PageController do
  use CodeHuntWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login_prompt(conn, _params) do
    render(conn, "login_prompt.html")
  end
end
