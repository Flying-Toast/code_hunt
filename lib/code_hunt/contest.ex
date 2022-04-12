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

  def list_players() do
    Repo.all(Player)
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
  Gets the top n players with the highest scores, excluding players with 0 points
  """
  def get_leaders(n) do
    list_players()
    |> Enum.map(&{&1, player_score(&1)})
    |> Enum.reject(fn {_, score} -> score == 0 end)
    |> Enum.sort_by(fn {_, score} -> score end)
    |> Enum.reverse()
    |> Enum.take(n)
  end
end
