defmodule Toggle.Migrations.Postgres do
  @moduledoc "Migrations for bootstrapping Toggle on Postgres"

  defdelegate up(opts \\ []), to: Toggle.Migrations.SQLite
  defdelegate down(opts \\ []), to: Toggle.Migrations.SQLite
end
