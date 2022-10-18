defmodule CodeHuntWeb.AdminController do
  require EEx
  use CodeHuntWeb, :controller
  alias CodeHunt.{Hunting, Contest, Telemetry, Site}

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

  def show_requests(conn, _params) do
    reqs = Telemetry.reverse_chronological_requests()

    render(conn, "show_events.html", events: reqs)
  end

  def ban_player(conn, %{"caseid" => caseid, "ban_state" => ban_state, "reason" => reason}) do
    case ban_state do
      "ban" ->
        Contest.set_ban_state_for_caseid(caseid, true)
        Contest.set_ban_reason_for_caseid(caseid, reason)

      "unban" ->
        Contest.set_ban_state_for_caseid(caseid, false)
        Contest.set_ban_reason_for_caseid(caseid, "")
    end

    redirect(conn, to: Routes.admin_path(conn, :index))
  end

  def ban_form(conn, _params) do
    render(conn, "ban_form.html")
  end

  def show_mod_messages(conn, _params) do
    messages = Site.list_mod_messages()
    render(conn, "show_mod_messages.html", messages: messages)
  end

  def mod_message_form(conn, _params) do
    render(conn, "mod_message_form.html")
  end

  def create_mod_message(conn, %{"caseid" => caseid, "message" => message}) do
    player = Contest.get_player_by_caseid!(caseid)
    Site.create_mod_message(player, message)

    redirect(conn, to: Routes.admin_path(conn, :show_mod_messages))
  end

  def delete_mod_message(conn, %{"id" => id}) do
    {int_id, ""} = Integer.parse(id)
    IO.puts(int_id)
    Site.delete_mod_message!(int_id)

    redirect(conn, to: Routes.admin_path(conn, :show_mod_messages))
  end
end
