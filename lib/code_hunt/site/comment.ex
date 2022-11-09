defmodule CodeHunt.Site.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeHunt.Contest

  schema "comments" do
    field :body, :string
    field :accepted, :boolean, default: false
    belongs_to :author, Contest.Player
    belongs_to :receiver, Contest.Player

    timestamps(type: :utc_datetime)
  end

  def post_comment_changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, max: 100, min: 1)
  end
end
