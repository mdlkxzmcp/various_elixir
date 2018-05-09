defmodule SocketGallowsWeb.HangmanChannel do
  require Logger
  use Phoenix.Channel

  @type response() :: {:ok | :noreply, Phoenix.Socket.t()}

  @spec join(room :: String.t(), list, Phoenix.Socket.t()) :: response()
  def join("hangman:game", _args, socket) do
    game = Hangman.new_game()
    socket = assign(socket, :game, game)

    {:ok, socket}
  end

  @spec handle_in(message :: String.t(), any(), Phoenix.Socket.t()) :: response()
  def handle_in("tally", _args, socket) do
    tally = socket.assigns.game |> Hangman.tally()
    push(socket, "tally", tally)

    {:noreply, socket}
  end

  def handle_in("make_move", guess, socket) do
    tally = socket.assigns.game |> Hangman.make_move(guess)
    push(socket, "tally", tally)

    {:noreply, socket}
  end

  def handle_in("new_game", _args, socket) do
    socket = socket |> assign(:game, Hangman.new_game())
    handle_in("tally", nil, socket)
  end

  def handle_in(message, _args, socket) do
    Logger.error("Unsupported message received: #{message}")

    {:noreply, socket}
  end
end
