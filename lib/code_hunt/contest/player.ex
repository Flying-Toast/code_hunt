defmodule CodeHunt.Contest.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :caseid, :string

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:caseid])
    |> validate_required([:caseid])
  end
end
