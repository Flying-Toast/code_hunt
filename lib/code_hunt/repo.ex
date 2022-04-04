defmodule CodeHunt.Repo do
  use Ecto.Repo,
    otp_app: :code_hunt,
    adapter: Ecto.Adapters.SQLite3
end
