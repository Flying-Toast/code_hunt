defmodule CodeHuntWeb.AdminController do
  require EEx
  use CodeHuntWeb, :controller
  alias CodeHunt.Hunting

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def gen_codesheet(conn, _params) do
    sheet = Hunting.create_code_sheet!()

    conn
    |> redirect(to: Routes.code_drop_path(conn, :show_code_sheet, sheet.id))
  end
end
