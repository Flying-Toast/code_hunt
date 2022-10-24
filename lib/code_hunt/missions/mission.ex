defmodule CodeHunt.Missions.Mission do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.{Contest, Hunting}

  schema "missions" do
    field :name, :string
    field :details_release_date, :utc_datetime
    field :details, :string
    field :end_date, :utc_datetime
    field :original_caseids, {:array, :string}
    has_many :players, Contest.Player
    has_many :drops, Hunting.CodeDrop

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mission, attrs) do
    mission
    |> cast(attrs, [:name, :details_release_date, :details, :end_date, :original_caseids])
    |> validate_required([:name, :details_release_date, :details, :end_date, :original_caseids])
    |> validate_length(:name, min: 1)
    |> validate_length(:details, min: 1)
  end
end
