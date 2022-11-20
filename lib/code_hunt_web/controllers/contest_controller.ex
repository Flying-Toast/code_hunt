defmodule CodeHuntWeb.ContestController do
  use CodeHuntWeb, :controller
  alias CodeHunt.{Contest, Site}

  def leaderboard(conn, _params) do
    leaders = Contest.get_leaders(10)
    CodeHunt.Telemetry.track_leaderboard_view(conn.assigns.me_player.caseid)
    render(conn, "leaderboard.html", leaders: leaders, link_to_full_leaderboard: true)
  end

  def full_leaderboard(conn, _params) do
    leaders = Contest.get_leaders(true)
    render(conn, "leaderboard.html", leaders: leaders, link_to_full_leaderboard: false)
  end

  def show_players(conn, _params) do
    players = Contest.list_players()

    render(conn, "show_players.html", players: players)
  end

  def msg(conn, %{"caseid" => caseid}) do
    player = Contest.get_player_by_caseid!(caseid)
    if player.banned do
      conn
      |> put_status(404)
      |> put_root_layout(false)
      |> put_view(CodeHuntWeb.ErrorView)
      |> render("404.html")
      |> halt()
    else
      show_form = conn.assigns.me_player.caseid == caseid
      earliest_claim = Contest.time_of_first_claim_or_nil(player)
      comments = Site.comments_posted_for_user(player)

      render(conn, "player_page.html", player: player, show_form: show_form, earliest_claim_or_nil: earliest_claim, comments: comments)
    end
  end

  def update_message(conn, %{"new_message" => new_message}) do
    if new_message != conn.assigns.me_player.msg do
      Contest.set_player_message(conn.assigns.me_player.caseid, new_message)
      CodeHunt.Telemetry.track_new_message(conn.assigns.me_player.caseid, new_message)
    end

    redirect(conn, to: Routes.contest_path(conn, :msg, conn.assigns.me_player.caseid))
  end

  def post_comment(conn, %{"body" => body, "receiver" => receiver_id}) do
    {receiver_id, _} = Integer.parse(receiver_id)

    receiver = Contest.get_player(receiver_id)
    if receiver do
      Site.post_comment(conn.assigns.me_player, receiver, %{body: body})

      conn
      |> redirect(to: Routes.contest_path(conn, :msg, receiver.caseid))
    else
      redirect(conn, to: Routes.page_path(conn, :index))
    end
  end

  def accept_comment(conn, %{"comment_id" => comment_id}) do
    comment = Site.get_comment!(comment_id)
    if comment.receiver.caseid == conn.assigns.me_player.caseid do
      Site.accept_comment(comment)
    end

    redirect(conn, to: Routes.contest_path(conn, :msg, comment.receiver.caseid))
  end

  def remove_comment(conn, %{"comment_id" => comment_id}) do
    comment = Site.get_comment!(comment_id)
    if comment.receiver.caseid == conn.assigns.me_player.caseid do
      Site.delete_comment(comment)
    end

    redirect(conn, to: Routes.contest_path(conn, :msg, conn.assigns.me_player.caseid))
  end
end
