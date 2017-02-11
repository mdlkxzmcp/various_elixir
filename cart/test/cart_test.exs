defmodule CartTest do
  use ExUnit.Case
  doctest Cart

  test "Create new cart returns an empty cart" do
    my_cart = Cart.create()
    assert Cart.empty?(my_cart)
  end
  test "An empty cart doesn't contain any products" do
    product = "dog food"
    cart = Cart.create()
    refute Cart.contains?(cart, product)
  end
  test "If you add an item the cart should contain it" do
    product = "coffee"
    cart = Cart.create()
           |> Cart.add(product)
    assert Cart.contains?(cart, product)
  end
  test "When an item is added to the cart, then the cart is no longer empty" do
    product = "milk"
    cart = Cart.create()
            |> Cart.add(product)
    refute Cart.empty?(cart)
  end
  test "When the only item is removed from the cart, the cart becomes empty" do
    product = "chocolate"
    cart = Cart.create()
           |> Cart.add(product)
           |> Cart.remove(product)
    assert Cart.empty?(cart)
  end
  test "When you count items in an empty cart, the product count is 0" do

  end
end
