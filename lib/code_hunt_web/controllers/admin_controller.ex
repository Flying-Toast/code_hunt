defmodule CodeHuntWeb.AdminController do
  require EEx
  use CodeHuntWeb, :controller
  alias CodeHunt.{Hunting, Contest, Telemetry}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def gen_codesheet(conn, _params) do
    sheet = Hunting.create_code_sheet!()

    conn
    |> redirect(to: Routes.code_drop_path(conn, :show_code_sheet, sheet.id))
  end

  def show_events(conn, _params) do
    events = Telemetry.reverse_chronological_events()

    render(conn, "show_events.html", events: events)
  end

  def ban_player(conn, %{"caseid" => caseid, "ban_state" => ban_state}) do
    case ban_state do
      "ban" ->
        Contest.set_ban_state_for_caseid(caseid, true)

      "unban" ->
        Contest.set_ban_state_for_caseid(caseid, false)
    end

    redirect(conn, to: Routes.admin_path(conn, :index))
  end

  def ban_form(conn, _params) do
    render(conn, "ban_form.html")
  end
end
