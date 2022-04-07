defmodule CodeHuntWeb.Router do
  use CodeHuntWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, {CodeHuntWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :session_assigns
  end

  def session_assigns(conn, _opts) do
    caseid = Plug.Conn.get_session(conn, :caseid)
    assign(conn, :caseid, caseid)
  end

  def require_login(conn, _opts) do
    if !conn.assigns.caseid do
      conn = put_session(conn, "return_to_url", Phoenix.Controller.current_path(conn))

      redirect(conn, to: CodeHuntWeb.Router.Helpers.page_path(conn, :login_prompt))
      |> halt()
    else
      conn
    end
  end

  def admin_only(conn, _opts) do
    if conn.assigns.caseid == "srs266" do
      conn
    else
      conn
      |> put_view(CodeHuntWeb.ErrorView)
      |> render("404.html")
      |> halt()
    end
  end

  # Public pages
  scope "/", CodeHuntWeb do
    pipe_through :browser

    get "/login", LoginController, :login
    get "/auth", LoginController, :auth
    get "/who", PageController, :login_prompt
  end

  # Pages that require login
  scope "/", CodeHuntWeb do
    pipe_through [:browser, :require_login]

    get "/", PageController, :index
    get "/claim/:secret_id", CodeDropController, :claim
    get "/top", ContestController, :leaderboard
  end

  scope "/admin", CodeHuntWeb do
    pipe_through [:browser, :require_login, :admin_only]

    get "/", AdminController, :index
    get "/generate-codesheet", AdminController, :gen_codesheet
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CodeHuntWeb.Telemetry
    end
  end
end
