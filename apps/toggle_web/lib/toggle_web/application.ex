defmodule ToggleWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ToggleWeb.Telemetry,
      # Start a worker by calling: ToggleWeb.Worker.start_link(arg)
      # {ToggleWeb.Worker, arg},
      # Start to serve requests, typically the last entry
      ToggleWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ToggleWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ToggleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
