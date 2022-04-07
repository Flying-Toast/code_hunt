defmodule CodeHuntWeb.AdminController do
  require EEx
  use CodeHuntWeb, :controller
  alias CodeHunt.{Hunting, Contest}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  @codesheet_template """
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="utf-8">
    <style>
    body {
    margin: 8px;
    }

    @page {
    margin: 0;
    size: letter;
    }
    </style>
  </head>

  <body>
    <table>
      <% 30 = length(svgs) %>

      <%= for row <- Enum.chunk_every(svgs, 5) do %>
        <tr>
          <%= for svg <- row do %>
            <td><%= svg %></td>
          <% end %>
        </tr>
      <% end %>
    </table>
  </body>
  </html>
  """
  EEx.function_from_string(:defp, :render_codesheet, @codesheet_template, [:svgs])

  def gen_codesheet(conn, _params) do
    sheet = Hunting.create_code_sheet!()

    svgs =
      for drop <- sheet.code_drops do
        encoded = Base.url_encode64(drop.secret_id)

        Routes.code_drop_url(conn, :claim, encoded)
        |> EQRCode.encode()
        |> EQRCode.svg(width: 175)
      end

    rendered = render_codesheet(svgs)

    html(conn, rendered)
  end

  def show_drops(conn, _params) do
    drops = Hunting.list_drops()

    render(conn, "show_drops.html", drops: drops)
  end

  def show_players(conn, _params) do
    players = Contest.list_players()

    render(conn, "show_players.html", players: players)
  end
end
