defmodule CodeHunt.Site do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias CodeHunt.{Repo, Telemetry}
  alias CodeHunt.Site.{ModMessage, Comment}

  def create_mod_message(player, message) do
    %ModMessage{}
    |> ModMessage.changeset(%{player_id: player.id, message: message})
    |> Repo.insert!()
  end

  def delete_mod_message!(id) do
    Repo.get(ModMessage, id)
    |> Repo.delete!()
  end

  def mod_messages_for(player) do
    Repo.all(from m in ModMessage, where: m.player_id == ^player.id, preload: [:player])
  end

  def mod_message_seen(msg) do
    if !msg.seen do
      msg
      |> ModMessage.changeset(%{seen: true, seen_date: DateTime.now!("Etc/UTC")})
      |> Repo.update()
    end
  end

  def list_mod_messages() do
    Repo.all(from m in ModMessage, preload: [:player], select: m)
  end

  def comments_posted_for_user(user) do
    Repo.all(from c in Comment, where: c.receiver_id == ^user.id, preload: [:author], order_by: [asc: :inserted_at])
  end

  @max_comments_per_author_per_player_page 5
  def post_comment(author, receiver, attrs) do
    expired_comments =
      Repo.all(
        from c in Comment,
        where: c.receiver_id == ^receiver.id and c.author_id == ^author.id,
        order_by: [desc: :inserted_at],
        limit: 100000000,
        offset: @max_comments_per_author_per_player_page - 1
      )
    for i <- expired_comments do
      Repo.delete!(i)
    end
    Telemetry.track_comment_post(author.caseid, receiver.caseid, attrs.body)

    %Comment{}
    |> change(author_id: author.id, receiver_id: receiver.id)
    |> change(accepted: true)
    |> Comment.post_comment_changeset(attrs)
    |> Repo.insert()
  end

  def get_comment!(id) do
    Repo.get!(Comment, id)
    |> Repo.preload([:receiver])
  end

  def accept_comment(comment) do
    comment
    |> change(accepted: true)
    |> Repo.update()
  end

  def delete_comment(comment) do
    Repo.delete(comment)
  end
end
