defmodule Turbo.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Turbo.Repo,
      TurboWeb.Endpoint,
      TurboWeb.DynamicSupervisor,
    ]

    opts = [strategy: :one_for_one, name: Turbo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    TurboWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
