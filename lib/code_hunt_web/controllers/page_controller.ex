defmodule CodeHuntWeb.PageController do
  use CodeHuntWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
