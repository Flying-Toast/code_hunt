defmodule CodeHuntWeb.CodeDropController do
  use CodeHuntWeb, :controller

  def claim(conn, %{"secret_id" => secret_id}) do
    drop = CodeHunt.Hunting.get_code_drop_by_base64encoded_secret_id(secret_id)

    if drop do
      if drop.claimed_by do
        render(conn, "already_claimed.html", drop: drop)
      else
        {:ok, _drop} = CodeHunt.Hunting.claim_code_drop(drop, conn.assigns[:caseid])
        render(conn, "successful_claim.html")
      end
    else
      render(conn, "invalid.html")
    end
  end
end
