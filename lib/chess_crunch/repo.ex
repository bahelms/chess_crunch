defmodule ChessCrunch.Repo do
  use Ecto.Repo,
    otp_app: :chess_crunch,
    adapter: Ecto.Adapters.Postgres
end
