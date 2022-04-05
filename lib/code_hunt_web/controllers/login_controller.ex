defmodule CodeHuntWeb.LoginController do
  use CodeHuntWeb, :controller

  plug :public_page

  defp public_page(conn, _opts) do
    assign(conn, :public_page, true)
  end

  def login(conn, params) do
    conn =
      if params["from"] do
        put_session(conn, "return_to_url", params["from"])
      else
        conn
      end

    redirect(conn, external: "https://login.case.edu/cas/login?service=#{Routes.login_url(conn, :auth)}")
  end

  def auth(conn, %{"ticket" => ticket}) do
    %{status_code: 200, body: body} = HTTPoison.get!("https://login.case.edu/cas/validate?ticket=#{ticket}&service=#{Routes.login_url(conn, :auth)}")

    case String.split(body, "\n", trim: true) do
      ["no"] ->
        render(conn, "failed.html")

      ["yes", caseid] ->
        conn = put_session(conn, "caseid", caseid)
        go_to_url = get_session(conn, "return_to_url") || "/"
        conn = delete_session(conn, "return_to_url")
        redirect(conn, to: go_to_url)
    end
  end
end
