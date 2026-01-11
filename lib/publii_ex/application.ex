defmodule PubliiEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    data_path = Path.join([System.user_home!(), ".publii-ex", "data"])
    File.mkdir_p!(data_path)

    children = [
# Start TwMerge cache
TwMerge.Cache, 
      PubliiExWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:publii_ex, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PubliiEx.PubSub},
      {CubDB, data_dir: data_path, name: PubliiEx.CubDB},
      # Start a worker by calling: PubliiEx.Worker.start_link(arg)
      # {PubliiEx.Worker, arg},
      # Start to serve requests, typically the last entry
      PubliiExWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PubliiEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PubliiExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
