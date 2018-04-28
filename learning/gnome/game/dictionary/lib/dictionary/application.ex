defmodule Dictionary.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Dictionary.WordList,
        start: {Dictionary.WordList, :start_link, []}
      }
    ]

    options = [
      name: Dictionary.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, options)
  end
end
