defmodule CodeHunt.Site.ModMessage do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.Contest

  schema "mod_messages" do
    field :message, :string
    field :seen, :boolean, default: false
    field :seen_date, :utc_datetime, default: nil
    belongs_to :player, Contest.Player

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mod_message, attrs) do
    mod_message
    |> cast(attrs, [:message, :player_id, :seen, :seen_date])
    |> validate_required([:message, :player_id, :seen])
    |> validate_length(:message, min: 1)
  end
end
