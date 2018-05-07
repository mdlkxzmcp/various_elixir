defmodule SocketGallows.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: SocketGallowsWeb.Endpoint,
        start: {SocketGallowsWeb.Endpoint, :start_link, []},
        type: :supervisor
      }
    ]

    opts = [strategy: :one_for_one, name: SocketGallows.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SocketGallowsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
