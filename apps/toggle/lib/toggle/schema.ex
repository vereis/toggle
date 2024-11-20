defmodule Toggle.Schema do
  @moduledoc false
  defmacro __using__(_opts) do
    quote generated: true do
      use Ecto.Schema
      use EctoModel.Queryable

      import Ecto.Changeset
      import Ecto.Query

      alias __MODULE__

      @type t :: %__MODULE__{}
    end
  end
end
