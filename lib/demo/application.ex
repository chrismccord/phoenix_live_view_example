defmodule Demo.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Demo.Repo,
      DemoWeb.Telemetry,
      DemoWeb.Endpoint,
      DemoWeb.Presence
    ]

    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    DemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
