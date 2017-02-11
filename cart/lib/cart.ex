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

  def add(cart, product) do
    cart ++ [product]
  end

  def remove(cart, product) do
    cart -- [product]
  end

  def contains?(cart, product) do
    cart |> Enum.member?(product)
  end

  def count(cart) do
    cart |> Enum.count()
  end
end
