defmodule CodeHunt.Contest do
  import Ecto.Query, warn: false
  alias CodeHunt.Repo

  alias CodeHunt.Contest.Player
  alias CodeHunt.Hunting
  alias CodeHunt.Telemetry

  @doc """
  Gets (creating if it doesn't exist) a player by their caseid
  """
  def get_or_create_player_by_caseid(caseid) do
    player = get_player_by_caseid_if_exists(caseid)

    if player do
      player
    else
      create_player!(%{caseid: caseid})
    end
  end

  def get_player(id) do
    Repo.get(Player, id)
    |> Repo.preload([:code_drops, :mod_messages, :mission, :trophies, trophies: :mission])
  end

  def todays_top_player() do
    today =
      DateTime.utc_now()
      |> DateTime.shift_zone!("America/New_York")
      |> then(&%{&1 | hour: 0, minute: 0, second: 0})
      |> DateTime.truncate(:second)

    top_player =
      Repo.one(
        from d in Hunting.CodeDrop,
        where: d.claim_date >= ^today,
        having: count(d.id) > 1,
        group_by: d.player_id,
        order_by: [desc: count(d.id), asc: min(d.claim_date)],
        select: {d.player_id, count(d.id)},
        limit: 1
      )

    case top_player do
      {pid, count} ->
        {Repo.one(from p in Player, where: p.id == ^pid, select: p.caseid), count}

      nil ->
        nil
    end
  end

  defp create_player!(attrs) do
    Telemetry.track_user_creation(attrs.caseid)

    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert!()
    |> Repo.preload([:code_drops, :mod_messages, :mission, :trophies, trophies: :mission])
  end

  def get_player_by_caseid!(caseid) do
    Repo.one!(from p in Player, where: p.caseid == ^caseid, preload: [:code_drops, :mod_messages, :mission, :trophies, trophies: :mission])
  end

  defp get_player_by_caseid_if_exists(caseid) do
    Repo.one(from p in Player, where: p.caseid == ^caseid, preload: [:code_drops, :mod_messages, :mission, :trophies, trophies: :mission])
  end

  def points_needed_for_mission_1, do: 5

  def is_admin(player) do
    caseid_is_admin(player.caseid)
  end

  def caseid_is_admin(caseid) do
    caseid in Application.fetch_env!(:code_hunt, :admins)
  end

  def list_players() do
    Repo.all(Player)
    |> Repo.preload([:code_drops])
  end

  def player_score(player) do
    Repo.one(from c in Hunting.CodeDrop, where: c.player_id == ^player.id, select: count())
  end

  # For sorting leaders
  defp unix_time_of_latest_claim(player) do
    player.code_drops
    |> Enum.map(&(&1.claim_date))
    |> Enum.max(DateTime)
    |> DateTime.to_unix()
  end

  def time_of_first_claim_or_nil(player) do
    player.code_drops
    |> Enum.map(&(&1.claim_date))
    |> Enum.min(DateTime, fn -> nil end)
  end

  @doc """
  Gets the top n players with the highest scores, excluding players with 0 points. Pass `true` as `n` parameter to retrieve all players.
  """
  def get_leaders(n) do
    leaders =
      list_players()
      |> Enum.reject(&(&1.banned))
      |> Enum.map(&{&1, player_score(&1)})
      |> Enum.reject(fn {_, score} -> score == 0 end)
      |> Enum.sort_by(fn {p, score} -> {-1 * score, unix_time_of_latest_claim(p)} end)

    if n == true do
      leaders
    else
      Enum.take(leaders, n)
    end
  end

  def set_ban_state_for_caseid(caseid, ban_state) do
    player = get_player_by_caseid_if_exists(caseid)
    true = player != nil

    player
    |> Player.changeset(%{banned: ban_state})
    |> Repo.update()
  end

  def set_ban_reason_for_caseid(caseid, reason) do
    player = get_player_by_caseid_if_exists(caseid)
    true = player != nil

    player
    |> Player.changeset(%{ban_reason: reason})
    |> Repo.update()
  end

  def set_player_message(caseid, message) do
    get_or_create_player_by_caseid(caseid)
    |> Player.changeset(%{msg: message})
    |> Repo.update()
  end

  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update!()
    |> Repo.preload([:trophies])
  end
end
