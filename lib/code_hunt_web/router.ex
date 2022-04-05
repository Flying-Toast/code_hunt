defmodule CodeHuntWeb.Router do
  use CodeHuntWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, {CodeHuntWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_caseid
    plug :private_pages
  end

  def assign_caseid(conn, _opts) do
    caseid = Plug.Conn.get_session(conn, :caseid)
    assign(conn, :caseid, caseid)
  end

  def private_pages(conn, _opts) do
    assign(conn, :public_page, false)
  end

  scope "/", CodeHuntWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/login", LoginController, :login
    get "/auth", LoginController, :auth
    get "/claim/:secret_id", CodeDropController, :claim
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
