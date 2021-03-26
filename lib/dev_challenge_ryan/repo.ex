defmodule DevChallengeRyan.Repo do
  use Ecto.Repo,
    otp_app: :dev_challenge_ryan,
    adapter: Ecto.Adapters.Postgres
end
