defmodule CodeHuntWeb.CodeDropController do
  use CodeHuntWeb, :controller
  alias CodeHunt.{Hunting, Contest}

  def claim(conn, %{"secret_id" => secret_id}) do
    drop = Hunting.get_code_drop_by_base64encoded_secret_id(secret_id)

    if drop do
      if drop.player do
        render(conn, "already_claimed.html", drop: drop)
      else
        player = Contest.get_player_by_caseid(conn.assigns.caseid)
        {:ok, _drop} = Hunting.claim_code_drop(drop, player)
        render(conn, "successful_claim.html")
      end
    else
      render(conn, "invalid.html")
    end
  end
end
