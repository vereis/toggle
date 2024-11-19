defmodule Toggle.Repo do
  use Ecto.Repo,
    otp_app: :toggle,
    adapter: Ecto.Adapters.SQLite3
end
