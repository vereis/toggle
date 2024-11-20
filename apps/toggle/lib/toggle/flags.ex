defmodule Toggle.Flags do
  @moduledoc """
  Provides a set of functions for managing feature flags.
  """

  alias Toggle.Flags.Flag
  alias Toggle.Repo

  @doc "Creates a new flag."
  @spec create_flag(attrs :: map()) :: {:ok, Flag.t()} | {:error, Ecto.Changeset.t()}
  def create_flag(attrs) do
    %Flag{}
    |> Flag.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a flag."
  @spec update_flag(flag :: Flag.t(), attrs :: map()) ::
          {:ok, Flag.t()} | {:error, Ecto.Changeset.t()}
  def update_flag(%Flag{} = flag, attrs) do
    flag
    |> Flag.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a flag."
  @spec delete_flag(flag :: Flag.t()) :: {:ok, Flag.t()} | {:error, Ecto.Changeset.t()}
  def delete_flag(%Flag{} = flag) do
    Repo.delete(flag)
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
    |> Repo.one()
  end

  @doc "Get all flags by the given filters."
  @spec list_flags(filters :: Keyword.t()) :: [Flag.t()]
  def list_flags(filters \\ []) do
    filters |> Flag.query() |> Repo.all()
  end

  @doc "Is the given flag enabled?"
  @spec enabled?(flag :: Flag.t()) :: boolean
  @spec enabled?(String.t()) :: boolean
  @spec enabled?(atom()) :: boolean
  def enabled?(%Flag{} = flag) do
    flag.enabled == true
  end

  def enabled?(flag_name) when is_binary(flag_name) or is_atom(flag_name) do
    case get_flag(name: flag_name) do
      %Flag{enabled: enabled?} -> enabled?
      nil -> false
    end
  end
end
