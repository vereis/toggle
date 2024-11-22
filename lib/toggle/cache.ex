defmodule Toggle.Cache do
  @moduledoc "Module responsible for caching values in memory."

  alias Toggle.Comptime
  alias Toggle.Flags.Flag

  @doc false
  @spec put!(Flag, Flag.t()) :: :ok
  def put!(Flag, flag) do
    multicast(Cachex, :put!, [
      :toggle_cache,
      flag.name,
      flag,
      [expire: Comptime.cache_ttl()]
    ])

    :ok
  end

  @doc false
  @spec delete!(Flag, Flag.t()) :: :ok
  def delete!(Flag, flag) do
    multicast(Cachex, :del!, [
      :toggle_cache,
      flag.name
    ])

    :ok
  end

  @doc false
  @spec get!(Flag, flag_name :: String.t()) :: Flag.t() | nil
  def get!(Flag, flag_name) do
    Cachex.get!(:toggle_cache, flag_name)
  end

  @doc false
  @spec reset!() :: :ok
  def reset! do
    Cachex.clear!(:toggle_cache)
    :ok
  end

  @doc false
  @spec reset_all!() :: :ok
  def reset_all! do
    multicast(Cachex, :clear!, [:toggle_cache])
    :ok
  end

  if Mix.env() == :test do
    defp multicast(module, function, args) do
      apply(module, function, args)
    end
  else
    defp multicast(module, function, args) do
      :erpc.multicast([node() | :erlang.nodes()], module, function, args)
    end
  end
end
