defmodule Toggle.Flags.Flag do
  @moduledoc """
  Schema for a feature flag as defined by `Toggle`.

  Provides utility functions for easily creating data. Note that reads to this schema may
  be cached depending on the given adapter.
  """

  use Toggle.Schema

  alias Toggle.Comptime

  schema Comptime.table_name(Flag) do
    field(:name, :string)
    field(:description, :string)
    field(:enabled, :boolean, default: false)
    field(:type, Ecto.Enum, values: [:boolean], default: :boolean)
    field(:meta, :map, default: %{})

    timestamps()
  end

  def changeset(%Flag{} = flag, attrs) do
    flag
    |> cast(attrs, [:name, :description, :enabled, :type, :meta])
    |> validate_required([:name, :type])
  end

  @impl EctoModel.Queryable
  def query(base_query \\ base_query(), filters) do
    filters
    |> Keyword.replace_lazy(:name, &to_string/1)
    |> Enum.reduce(base_query, fn
      {key, value}, query ->
        apply_filter(query, {key, value})
    end)
  end
end
