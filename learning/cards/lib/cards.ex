defmodule Cards do
  @moduledoc """
    Provides methods for creating and handling a deck of cards.
  """

  @values Application.get_env(:cards, :values)
  @suits Application.get_env(:cards, :suits)

  @doc """
    Returns a list of strings representing a deck of playing cards.
  """
  def create_hand(hand_size) do
    create_deck()
    |> shuffle()
    |> deal(hand_size)
  end

  def create_deck do
    for value <- @values, suit <- @suits do
      "#{value} of #{suit}"
    end
  end

  @doc """
    Divides a deck into a hand of size `hand_size`
    and the remainder of the deck.

    ## Examples

      iex> deck = Cards.create_deck
      iex> {hand, _deck} = Cards.deal(deck, 1)
      iex> hand
      ["Ace of Spades"]

  """
  def deal(deck, hand_size) do
    Enum.split(deck, hand_size)
  end


  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  @doc """
  Determines whether a deck contains a given card.

  ## Examples

    iex> deck = Cards.create_deck
    iex> Cards.contains?(deck, "Ace of Spades")
    true

  """
  def contains?(deck, card) do
    Enum.member?(deck, card)
  end

  def save(deck, filename) do
    binary = :erlang.term_to_binary(deck)
    File.write(filename, binary)
  end

  def load(filename) do
    case File.read(filename) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      {:error, _reason} -> "That file does not exist"
    end
  end

end
