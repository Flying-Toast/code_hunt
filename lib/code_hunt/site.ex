defmodule CodeHunt.Site do
  import Ecto.Query, warn: false
  alias CodeHunt.Repo
  alias CodeHunt.Site.ModMessage

  def create_mod_message(player, message) do
    %ModMessage{}
    |> ModMessage.changeset(%{player_id: player.id, message: message})
    |> Repo.insert!()
  end

  def delete_mod_message!(id) do
    Repo.get(ModMessage, id)
    |> Repo.delete!()
  end

  def mod_messages_for(player) do
    Repo.all(from m in ModMessage, where: m.player_id == ^player.id, preload: [:player])
  end

  def mod_message_seen(msg) do
    msg
    |> ModMessage.changeset(%{seen: true})
    |> Repo.update()
  end

  def list_mod_messages() do
    Repo.all(from m in ModMessage, preload: [:player], select: m)
  end
end
