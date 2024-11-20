defmodule Toggle.Migrations.SQLite do
  @moduledoc "Migrations for bootstrapping Toggle on SQLite"

  use Ecto.Migration

  def up(opts) do
    table_name = Keyword.get(opts, :table, "toggle_flags")

    create_if_not_exists table(table_name) do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:enabled, :boolean, null: false, default: false)
      add(:type, :string, null: false, default: "boolean")
      add(:meta, :map)

      timestamps()
    end

    create_if_not_exists(index(table_name, [:name], unique: true))
  end

  def down(opts) do
    table_name = Keyword.get(opts, :table, "toggle_flags")
    drop_if_exists(table(table_name))
  end
end
