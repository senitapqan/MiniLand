defmodule MiniLand.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MiniLandWeb.Telemetry,
      MiniLand.Repo,
      {DNSCluster, query: Application.get_env(:mini_land, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MiniLand.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MiniLand.Finch},
      # Start a worker by calling: MiniLand.Worker.start_link(arg)
      # {MiniLand.Worker, arg},
      # Start to serve requests, typically the last entry
      MiniLandWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MiniLand.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MiniLandWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
