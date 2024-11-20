defmodule Toggle.Migrations.Postgres do
  @moduledoc "Migrations for bootstrapping Toggle on Postgres"

  alias Toggle.Migrations.SQLite

  defdelegate up(opts \\ []), to: SQLite
  defdelegate down(opts \\ []), to: SQLite
end
