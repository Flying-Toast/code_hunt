defmodule CodeHuntWeb.CodeDropController do
  use CodeHuntWeb, :controller
  alias CodeHunt.Hunting

  def claim(conn, %{"secret_id" => secret_id}) do
    drop = Hunting.get_code_drop_by_base64encoded_secret_id(secret_id)

    if drop do
      if drop.player do
        render(conn, "already_claimed.html", drop: drop)
      else
        {:ok, _drop} = Hunting.claim_code_drop(drop, conn.assigns.me_player)
        render(conn, "successful_claim.html")
      end
    else
      render(conn, "invalid.html")
    end
  end


  def show_drops(conn, _params) do
    drops = Hunting.list_drops()

    render(conn, "show_drops.html", drops: drops)
  end
end
