defmodule Toggle.Comptime do
  @moduledoc "Module for handling compile-time parameters and configuration."

  alias Toggle.Flags.Flag

  @table_names %{
    Flag => Application.compile_env(:toggle, :flag_table_name, "toggle_flags")
  }

  def table_name(schema), do: @table_names[schema]
end
