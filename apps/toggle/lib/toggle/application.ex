defmodule Toggle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Toggle.Repo,
      {Ecto.Migrator, repos: Application.fetch_env!(:toggle, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:toggle, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Toggle.PubSub},
      {Cachex, [:toggle_cache]}
      # Start a worker by calling: Toggle.Worker.start_link(arg)
      # {Toggle.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Toggle.Supervisor)
  end

  defp skip_migrations? do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
