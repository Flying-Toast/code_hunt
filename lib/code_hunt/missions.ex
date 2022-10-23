defmodule CodeHunt.Missions do
  import Ecto.Query, warn: false
  alias CodeHunt.Repo

  alias CodeHunt.Missions.Mission

  def mission_active?(mission) do
    mission != nil and :gt == DateTime.compare(mission.end_date, DateTime.utc_now())
  end

  def assigned_to_mission?(player, mission) do
    player.mission_id == mission.id
  end

  def get_mission(id) do
    Repo.get!(Mission, id)
    |> Repo.preload([:players, :drops])
  end

  def list_missions() do
    Repo.all(Mission, preload: [:players, :drops])
  end

  def create_mission(name, details, release_date, end_date) do
    %Mission{}
    |> Mission.changeset(%{name: name, details: details, details_release_date: release_date, end_date: end_date})
    |> Repo.insert()
  end
end
