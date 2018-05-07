defmodule SocketGallowsWeb.HangmanChannel do
  use Phoenix.Channel

  def join("hangman:game", _args, socket) do
    {:ok, socket}
  end
end
