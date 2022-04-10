defmodule CodeHuntWeb.LoginController do
  use CodeHuntWeb, :controller

  def login(conn, _params) do
    redirect(conn, external: "https://login.case.edu/cas/login?service=#{Routes.login_url(conn, :auth)}")
  end

  def auth(conn, %{"ticket" => ticket}) do
    %{status_code: 200, body: body} = HTTPoison.get!("https://login.case.edu/cas/validate?ticket=#{ticket}&service=#{Routes.login_url(conn, :auth)}")

    case String.split(body, "\n", trim: true) do
      ["no"] ->
        render(conn, "failed.html")

      ["yes", caseid] ->
        conn = put_session(conn, "caseid", caseid)
        go_to_url = get_session(conn, "return_to_url") || Routes.page_path(conn, :index)
        conn = delete_session(conn, "return_to_url")
        redirect(conn, to: go_to_url)
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session("caseid")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
