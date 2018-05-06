defmodule GallowsWeb.Views.Helpers.GameStateHelper do
  import Phoenix.HTML, only: [raw: 1]

  @responses %{
    :won => {:success, "You Won!"},
    :lost => {:danger, "You Lost!"},
    :good_guess => {:success, "Good guess!"},
    :bad_guess => {:warning, "Bad guess!"},
    :already_used => {:info, "You already guessed that."}
  }

  @spec game_state(atom) :: String.t()
  def game_state(state) when is_atom(state) do
    @responses[state]
    |> alert()
  end

  defp alert(nil), do: ""

  defp alert({class, message}) do
    """
    <div class="alert alert-#{class}">
      #{message}
    </div>
    """
    |> raw()
  end
end
