defmodule CodeHuntWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use CodeHuntWeb, :controller
      use CodeHuntWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: CodeHuntWeb

      import Plug.Conn
      import CodeHuntWeb.Gettext
      alias CodeHuntWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/code_hunt_web/templates",
        namespace: CodeHuntWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())

      def format_datetime(datetime, :with_seconds) do
        datetime
        |> DateTime.shift_zone("America/New_York")
        |> elem(1)
        |> Calendar.strftime("%m/%d/%y %-I:%M::%S %p")
      end

      def format_datetime(datetime, :no_seconds) do
        datetime
        |> DateTime.shift_zone("America/New_York")
        |> elem(1)
        |> Calendar.strftime("%m/%d/%y %-I:%M %p")
      end
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {CodeHuntWeb.LayoutView, "live.html"}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import CodeHuntWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import CodeHuntWeb.ErrorHelpers
      import CodeHuntWeb.Gettext
      alias CodeHuntWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
