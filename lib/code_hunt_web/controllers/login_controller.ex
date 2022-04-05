defmodule CodeHuntWeb.LoginController do
  use CodeHuntWeb, :controller

  def login(conn, _params) do
    host = get_req_header(conn, "host")

    redirect(conn, external: "https://login.case.edu/cas/login?service=#{conn.scheme}://#{host}/auth")
  end

  def auth(conn, %{"ticket" => ticket} = params) do
    host = get_req_header(conn, "host")
    service = "#{conn.scheme}://#{host}/auth"

    %{status_code: 200, body: body} = HTTPoison.get!("https://login.case.edu/cas/validate?ticket=#{ticket}&service=#{service}")

    case String.split(body, "\n", trim: true) do
      ["no"] ->
        render(conn, "failed.html")

      ["yes", caseid] ->
        conn = put_session(conn, :caseid, caseid)
        redirect(conn, to: "/")
    end
  end
end
