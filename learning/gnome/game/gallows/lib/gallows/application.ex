defmodule Gallows.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: GallowsWeb.Endpoint,
        start: {GallowsWeb.Endpoint, :start_link, []},
        type: :supervisor
      }
    ]

    opts = [strategy: :one_for_one, name: Gallows.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    GallowsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
