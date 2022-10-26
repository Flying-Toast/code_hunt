defmodule CodeHunt.Missions do
  import Ecto.Query, warn: false
  alias CodeHunt.{Repo, Hunting, Contest}
  alias CodeHunt.Missions.{Mission, Trophy}

  def mission_active?(mission) do
    mission != nil and :gt == DateTime.compare(mission.end_date, DateTime.utc_now())
  end

  def assigned_to_mission?(player, mission) do
    player.mission_id == mission.id
  end

  def num_drops_claimed_in_mission(player_id, mission_id) do
    Repo.one(from d in Hunting.CodeDrop, where: d.player_id == ^player_id and d.mission_id == ^mission_id, select: count())
  end

  def caseids_who_participated_in_mission(mission) do
    mission.original_caseids
    |> Enum.map(fn caseid -> Repo.one(from p in Contest.Player, where: p.caseid == ^caseid) end)
    |> Enum.filter(fn player -> num_drops_claimed_in_mission(player.id, mission.id) > 0 end)
    |> Enum.reject(fn player -> player.banned end)
    |> Enum.map(fn player -> player.caseid end)
  end

  def create_trophy(player, mission) do
    %Trophy{}
    |> Trophy.changeset(%{player_id: player.id, mission_id: mission.id})
    |> Repo.insert()
  end

  def unscanned_tokens_remaining(mission) do
    Repo.one(from d in Hunting.CodeDrop, where: d.mission_id == ^mission.id and is_nil(d.player_id), select: count())
  end

  def num_trophies(player) do
    Repo.one!(from t in Trophy, where: t.player_id == ^player.id, select: count())
  end

  def get_mission(id) do
    Repo.get!(Mission, id)
    |> Repo.preload([:players, :drops])
  end

  def list_missions() do
    Repo.all(Mission, preload: [:players, :drops])
  end

  def create_mission(name, details, release_date, end_date, original_caseids) do
    %Mission{}
    |> Mission.changeset(%{name: name, details: details, details_release_date: release_date, end_date: end_date, original_caseids: original_caseids})
    |> Repo.insert()
  end
end
