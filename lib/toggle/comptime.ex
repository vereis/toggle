defmodule Toggle.Comptime do
  @moduledoc "Module for handling compile-time parameters and configuration."

  alias Toggle.Flags.Flag

  @table_names %{
    Flag => Application.compile_env(:toggle, :flag_table_name, "toggle_flags")
  }

  @cache_ttl Application.compile_env(:toggle, :cache_ttl, :timer.minutes(1))

  @doc "Returns the name of the database table used to store flags. Defaults to \"toggle_flags\"."
  def table_name(schema), do: @table_names[schema]

  @doc "Returns the ttl for cached flags. Defaults to 1 minute."
  def cache_ttl, do: @cache_ttl
end
