defmodule Toggle.Flags do
  @moduledoc """
  Provides a set of functions for managing feature flags.

  A feature flag in `Toggle` is a named boolean value that can be enabled or disabled on two levels:

  - Globally: The flag is either enabled or disabled for all resources.
  - Individually: The flag can be enabled or disabled for a specific resource.

  A resource is a key-value pair that can be used to enable or disable a flag for a specific entity,
  for example: `org_id: 123` or `user_id: 456`.

  When a flag is enabled for a resource, that resource's value takes precedence over the global value,
  for example:

  ```elixir
  iex> Flags.create_flag(%{name: "my_flag", enabled: true})
  iex> Flags.enabled?("my_flag")
  true
  iex> Flags.enabled?("my_flag", org_id: 123)
  true
  iex> Flags.disable!("my_flag", org_id: 123)
  iex> Flags.enabled?("my_flag")
  true
  iex> Flags.enabled?("my_flag", org_id: 353)
  true
  iex> Flags.enabled?("my_flag", org_id: 123)
  false
  ```
  """

  import Toggle.Comptime, only: [repo: 0]

  alias Toggle.Flags.Flag

  @type resource_key :: atom() | String.t() | number()
  @type resource_value :: atom() | String.t() | number()

  @type resource :: [{resource_key(), resource_value()}]

  @doc "Creates a new flag."
  @spec create_flag(attrs :: map()) :: {:ok, Flag.t()} | {:error, Ecto.Changeset.t()}
  def create_flag(attrs) do
    %Flag{}
    |> Flag.changeset(attrs)
    |> repo().insert()
  end

  @doc "Updates a flag."
  @spec update_flag(flag :: Flag.t(), attrs :: map()) ::
          {:ok, Flag.t()} | {:error, Ecto.Changeset.t()}
  def update_flag(%Flag{} = flag, attrs) do
    flag
    |> Flag.changeset(attrs)
    |> repo().update()
  end

  @doc "Deletes a flag."
  @spec delete_flag(flag :: Flag.t()) :: {:ok, Flag.t()} | {:error, Ecto.Changeset.t()}
  def delete_flag(%Flag{} = flag) do
    repo().delete(flag)
  end

  @doc "Get a flag by the given filters."
  @spec get_flag(filters :: Keyword.t()) :: Flag.t() | nil
  @spec get_flag(String.t() | atom()) :: Flag.t() | nil
  @spec get_flag(String.t() | atom(), filters :: Keyword.t()) :: Flag.t() | nil
  def get_flag(flag_name, filters) when is_binary(flag_name) or is_atom(flag_name) do
    get_flag(Keyword.put(filters, :name, flag_name))
  end

  def get_flag(flag_name) when is_binary(flag_name) or is_atom(flag_name) do
    get_flag(name: flag_name)
  end

  def get_flag(filters) when is_list(filters) do
    filters
    |> Flag.query()
    |> repo().one()
  end

  @doc "Get all flags by the given filters."
  @spec list_flags(filters :: Keyword.t()) :: [Flag.t()]
  def list_flags(filters \\ []) do
    filters |> Flag.query() |> repo().all()
  end

  @doc "Is the given flag enabled?"
  @spec enabled?(flag :: Flag.t()) :: boolean
  @spec enabled?(String.t()) :: boolean
  @spec enabled?(atom()) :: boolean
  def enabled?(%Flag{} = flag) do
    flag.enabled == true
  end

  def enabled?(flag_name) when is_binary(flag_name) or is_atom(flag_name) do
    repo().exists?(Flag.query(name: flag_name, enabled: true))
  end

  @doc "Returns if the given flag is enabled for the given resource."
  @spec enabled?(flag :: Flag.t(), meta :: resource()) :: boolean
  def enabled?(nil, _resource) do
    false
  end

  def enabled?(%Flag{meta: meta} = flag, [{meta_key, meta_value}]) do
    globally_enabled? = flag.enabled
    individually_enabled? = Map.get(meta, encode_meta!(meta_key, meta_value))

    cond do
      globally_enabled? and individually_enabled? == false -> false
      globally_enabled? -> true
      individually_enabled? -> true
      true -> false
    end
  end

  def enabled?(flag_name, [{meta_key, meta_value}]) when is_binary(flag_name) or is_atom(flag_name) do
    flag_name
    |> get_flag()
    |> enabled?([{meta_key, meta_value}])
  end

  @doc "Is the given flag disabled?"
  @spec disabled?(flag :: Flag.t()) :: boolean
  @spec disabled?(String.t()) :: boolean
  @spec disabled?(atom()) :: boolean
  def disabled?(flag_or_flag_name) do
    not enabled?(flag_or_flag_name)
  end

  @doc "Returns if the given flag is disabled for the given entity."
  def disabled?(flag_or_flag_name, meta) do
    not enabled?(flag_or_flag_name, meta)
  end

  @doc "Globally enables the given flag. Will create the given flag if it does not exist."
  @spec enable!(flag :: Flag.t()) :: :ok
  @spec enable!(String.t()) :: :ok
  @spec enable!(atom()) :: :ok
  def enable!(%Flag{} = flag) do
    {:ok, _flag} = update_flag(flag, %{enabled: true})
    :ok
  end

  def enable!(flag_name) do
    repo().transaction(fn ->
      flag_name
      |> get_flag()
      |> case do
        nil ->
          create_flag(%{name: flag_name, enabled: true})

        flag ->
          enable!(flag)
      end
    end)

    :ok
  end

  @doc "Enable the given flag for the given resource. Will create the given flag if it does not exist."
  @spec enable!(flag :: Flag.t(), meta :: resource()) :: :ok
  def enable!(%Flag{meta: meta} = flag, [{meta_key, meta_value}]) do
    patched_meta = Map.put(meta, encode_meta!(meta_key, meta_value), true)
    {:ok, _flag} = update_flag(flag, %{meta: patched_meta})
    :ok
  end

  def enable!(flag_name, [{meta_key, meta_value}]) do
    repo().transaction(fn ->
      flag_name
      |> get_flag()
      |> case do
        nil ->
          create_flag(%{
            name: flag_name,
            enabled: false,
            meta: %{encode_meta!(meta_key, meta_value) => true}
          })

        flag ->
          enable!(flag, [{meta_key, meta_value}])
      end
    end)

    :ok
  end

  @doc "Globally disables the given flag. Will create the given flag if it does not exist."
  @spec disable!(flag :: Flag.t()) :: :ok
  @spec disable!(String.t()) :: :ok
  @spec disable!(atom()) :: :ok
  def disable!(%Flag{} = flag) do
    {:ok, _flag} = update_flag(flag, %{enabled: false})
    :ok
  end

  def disable!(flag_name) do
    repo().transaction(fn ->
      flag_name
      |> get_flag()
      |> case do
        nil ->
          create_flag(%{name: flag_name, enabled: false})

        flag ->
          disable!(flag)
      end
    end)

    :ok
  end

  @doc "Disable the given flag for the given resource. Will create the given flag if it does not exist."
  @spec disable!(flag :: Flag.t(), meta :: resource()) :: :ok
  def disable!(%Flag{meta: meta} = flag, [{meta_key, meta_value}]) do
    patched_meta = Map.put(meta, encode_meta!(meta_key, meta_value), false)
    {:ok, _flag} = update_flag(flag, %{meta: patched_meta})
    :ok
  end

  def disable!(flag_name, [{meta_key, meta_value}]) do
    repo().transaction(fn ->
      flag_name
      |> get_flag()
      |> case do
        nil ->
          create_flag(%{
            name: flag_name,
            enabled: false,
            meta: %{encode_meta!(meta_key, meta_value) => false}
          })

        flag ->
          disable!(flag, [{meta_key, meta_value}])
      end
    end)

    :ok
  end

  @doc false
  @spec encode_meta!(meta_key :: resource_key(), meta_value :: resource_value()) :: String.t()
  def encode_meta!(meta_key, meta_value) do
    to_string(meta_key) <> "::" <> to_string(meta_value)
  end

  @doc false
  @spec decode_meta!(string :: String.t()) :: resource()
  def decode_meta!(string, mapper \\ fn meta_key, meta_value -> [{meta_key, meta_value}] end) do
    [meta_key, meta_value] = String.split(string, "::")
    mapper.(meta_key, meta_value)
  end
end
