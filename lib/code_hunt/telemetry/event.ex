defmodule CodeHunt.Telemetry.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :event, :map, null: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:event])
    |> validate_required([:event])
  end
end
