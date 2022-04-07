defmodule CodeHunt.Hunting do
  import Ecto.Query, warn: false
  alias CodeHunt.Repo

  alias CodeHunt.Hunting.CodeDrop

  def get_code_drop_by_base64encoded_secret_id(secret_id) do
    case Base.url_decode64(secret_id) do
      {:ok, secret_id} ->
        Repo.one!(from c in CodeDrop, where: c.secret_id == ^secret_id, preload: [:player])

      _ ->
        nil
    end
  end

  defp generate_unused_secret_id() do
    id = :crypto.strong_rand_bytes(33)

    if get_code_drop_by_base64encoded_secret_id(id) do
      generate_unused_secret_id()
    else
      id
    end
  end

  def create_code_drop!() do
    %CodeDrop{secret_id: generate_unused_secret_id()}
    |> CodeDrop.changeset(%{})
    |> Repo.insert!()
  end

  def list_drops() do
    Repo.all(from d in CodeDrop, preload: [:player], select: d)
  end

  def claim_code_drop(drop, player) do
    nil = drop.player
    drop
    |> CodeDrop.changeset(%{player_id: player.id, claim_date: DateTime.now!("Etc/UTC")})
    |> Repo.update()
  end
end
