defmodule Anoma.Repo do
  use Ecto.Repo,
    otp_app: :anoma,
    adapter: Ecto.Adapters.Postgres
end
