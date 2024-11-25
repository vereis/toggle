defmodule Toggle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      maybe_add_repo([
        {Cachex, [:toggle_cache]},
        ToggleWeb.Telemetry,
        {DNSCluster, query: Application.get_env(:toggle, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Toggle.PubSub},
        ToggleWeb.Endpoint
      ])

    Supervisor.start_link(children, strategy: :one_for_one, name: Toggle.Supervisor)
  end

  # Only start the repo if it's available (i.e. for local development or testing)
  defp maybe_add_repo(children) do
    case Code.ensure_loaded(Toggle.Repo) do
      {:module, Toggle.Repo} -> [Toggle.Repo | children]
      _otherwise -> children
    end
  end
end
