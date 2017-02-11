defmodule Cart do
  @moduledoc """
  Documentation for Cart.
  """
  def create do
    []
  end

  def empty?(cart) do
    cart == []
  end

  def add(_, product) do
    [product]
  end

  def remove(cart, product) do
    []
  end

  def contains?(cart, product) do
    cart == [product]
  end
end
