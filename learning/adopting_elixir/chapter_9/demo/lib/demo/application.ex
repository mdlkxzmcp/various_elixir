defmodule Demo.Application do
  use Application

  def start(_type, _args) do
    ecto_repo = %{
      id: Demo.Repo,
      start: {Demo.Repo, :start_link, []},
      type: :supervisor
    }

    endpoint = %{
      id: DemoWeb.Endpoint,
      start: {DemoWeb.Endpoint, :start_link, []},
      type: :supervisor
    }

    children = [
      ecto_repo,
      endpoint
    ]

    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    DemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
