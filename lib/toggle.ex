defmodule Toggle do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias Toggle.Cache
  alias Toggle.Flags
  alias Toggle.Flags.Flag

  defdelegate enable!(flag_name), to: Flags
  defdelegate enable!(flag_name, resource), to: Flags
  defdelegate disable!(flag_name), to: Flags
  defdelegate disable!(flag_name, resource), to: Flags

  def enabled?(flag_name) do
    Flags.enabled?(Cache.get!(Flag, flag_name) || flag_name)
  end

  def enabled?(flag_name, resource) do
    Flags.enabled?(Cache.get!(Flag, flag_name) || flag_name, resource)
  end

  def disabled?(flag_name) do
    Flags.enabled?(Cache.get!(Flag, flag_name) || flag_name)
  end

  def disabled?(flag_name, resource) do
    Flags.enabled?(Cache.get!(Flag, flag_name) || flag_name, resource)
  end
end
