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
    me =
      if caseid do
        CodeHunt.Contest.get_or_create_player_by_caseid(caseid)
      else
        nil
      end

    assign(conn, :me_player, me)
  end

  def require_login(conn, _opts) do
    if !conn.assigns.me_player do
      conn = put_session(conn, "return_to_url", Phoenix.Controller.current_path(conn))

      redirect(conn, to: CodeHuntWeb.Router.Helpers.page_path(conn, :login_prompt))
      |> halt()
    else
      conn
    end
  end

  def admin_only(conn, _opts) do
    if conn.assigns.me_player && CodeHunt.Contest.is_admin(conn.assigns.me_player) do
      conn
    else
      conn
      |> put_status(404)
      |> put_root_layout(false)
      |> put_view(CodeHuntWeb.ErrorView)
      |> render("404.html")
      |> halt()
    end
  end

  def deny_banned_players(conn, _opts) do
    if conn.assigns.me_player && conn.assigns.me_player.banned do
      to_path = CodeHuntWeb.Router.Helpers.page_path(conn, :index)
      if Phoenix.Controller.current_path(conn) != to_path do
        redirect(conn, to: to_path)
        |> halt()
      else
        conn
      end
    else
      conn
    end
  end

  # Public pages
  scope "/", CodeHuntWeb do
    pipe_through :browser

    get "/login", LoginController, :login
    get "/auth", LoginController, :auth
    get "/who", PageController, :login_prompt
  end

  # Pages that require login, banned players ARE ALLOWED to access
  scope "/", CodeHuntWeb do
    pipe_through [:browser, :require_login]

    get "/logout", LoginController, :logout
  end

  # Pages that require login, banned players ARE NOT ALLOWED to access
  scope "/", CodeHuntWeb do
    pipe_through [:browser, :require_login, :deny_banned_players]

    get "/", PageController, :index
    get "/claim/:secret_id", CodeDropController, :claim
    get "/top", ContestController, :leaderboard
    get "/all", ContestController, :full_leaderboard
    get "/msg/:caseid", ContestController, :msg
    post "/post-msg", ContestController, :update_message
  end

  scope "/admin", CodeHuntWeb do
    pipe_through [:browser, :admin_only]

    get "/", AdminController, :index
    get "/generate-codesheet", AdminController, :gen_codesheet
    get "/codesheet/:id", CodeDropController, :show_code_sheet
    get "/drops", CodeDropController, :show_drops
    get "/players", ContestController, :show_players
    get "/event-log", AdminController, :show_events
    post "/ban/", AdminController, :ban_player
    get "/ban-form", AdminController, :ban_form
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
