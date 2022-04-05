defmodule CodeHuntWeb.CodeDropController do
  use CodeHuntWeb, :controller

  def claim(conn, %{"secret_id" => secret_id}) do
    if !conn.assigns[:caseid] do
      render(conn, "invalid.html")
    else
      drop = CodeHunt.Hunting.get_code_drop_by_base64encoded_secret_id(secret_id)
      if drop do
        if drop.claimed_by do
          render(conn, "already_claimed.html", drop: drop)
        else
          {:ok, drop} = CodeHunt.Hunting.claim_code_drop(drop, conn.assigns[:caseid])
          render(conn, "successful_claim.html", drop: drop)
        end
      else
        render(conn, "invalid.html")
      end
    end
  end
end
