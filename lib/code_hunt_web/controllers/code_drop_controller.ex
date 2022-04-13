defmodule CodeHuntWeb.CodeDropController do
  use CodeHuntWeb, :controller
  alias CodeHunt.{Hunting, Contest}

  def claim(conn, %{"secret_id" => secret_id}) do
    drop = Hunting.get_code_drop_by_base64encoded_secret_id(secret_id)

    if drop do
      if drop.player do
        render(conn, "already_claimed.html", drop: drop)
      else
        if Contest.is_admin(conn.assigns.me_player) do
          text(conn, "Admins can't claim codes, silly. That would be cheating.")
        else
          {:ok, _drop} = Hunting.claim_code_drop(drop, conn.assigns.me_player)
          finished_mission_1 = length(conn.assigns.me_player.code_drops) == Contest.points_needed_for_mission_1()
          if finished_mission_1 do
            render(conn, "mission_completed.html", mission_num: 1)
          else
            render(conn, "successful_claim.html")
          end
        end
      end
    else
      render(conn, "invalid.html")
    end
  end


  def show_drops(conn, _params) do
    drops = Hunting.list_drops()

    render(conn, "show_drops.html", drops: drops)
  end

  def show_code_sheet(conn, %{"id" => id}) do
    sheet = Hunting.get_code_sheet!(id)

    conn
    |> put_root_layout(false)
    |> render("show_sheet.html", sheet: sheet)
  end
end
