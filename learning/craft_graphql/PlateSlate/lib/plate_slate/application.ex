defmodule PlateSlate.Application do
  use Application

  def start(_type, _args) do
    ecto_repo = %{
      id: PlateSlate.Repo,
      start: {PlateSlate.Repo, :start_link, []},
      type: :supervisor
    }

    endpoint = %{
      id: PlateSlateWeb.Endpoint,
      start: {PlateSlateWeb.Endpoint, :start_link, []},
      type: :supervisor
    }

    children = [
      ecto_repo,
      endpoint
    ]

    opts = [strategy: :one_for_one, name: PlateSlate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    PlateSlateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
