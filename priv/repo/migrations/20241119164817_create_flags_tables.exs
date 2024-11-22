defmodule Toggle.Repo.Migrations.CreateFlagsTables do
  use Ecto.Migration

  def up do
    Toggle.Migrations.SQLite.up(table: "toggle_flags")
  end

  def down do
    Toggle.Migrations.SQLite.down(table: "toggle_flags")
  end
end
