defmodule MiniLand.Repo do
  use Ecto.Repo,
    otp_app: :mini_land,
    adapter: Ecto.Adapters.Postgres
end
