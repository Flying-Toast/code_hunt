defmodule CodeHunt.Contest do
  import Ecto.Query, warn: false
  alias CodeHunt.Repo

  alias CodeHunt.Contest.Player
  alias CodeHunt.Hunting

  @doc """
  Gets (creating if it doesn't exist) a player by their caseid
  """
  def get_player_by_caseid(caseid) do
    player = Repo.one(from p in Player, where: p.caseid == ^caseid)

    if player do
      player
    else
      create_player!(%{caseid: caseid})
    end
  end

  defp create_player!(attrs) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert!()
  end

  def player_score(player) do
    Repo.one(from c in Hunting.CodeDrop, where: c.player_id == ^player.id, select: count())
  end

  @doc """
  Gets the top n players with the highest scores
  """
  def get_leaders(n) do
    Repo.all(from p in Player, left_join: d in Hunting.CodeDrop, on: d.player_id == p.id, order_by: [desc: count(d.player_id)], select: {p, count(d.player_id)}, limit: ^n)
  end
end
