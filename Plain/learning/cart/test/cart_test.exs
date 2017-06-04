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
  test "If you add an product the cart should contain it" do
    product = "coffee"
    cart = Cart.create()
           |> Cart.add(product)
    assert Cart.contains?(cart, product)
  end
  test "When an product is added to the cart, then the cart is no longer empty" do
    product = "milk"
    cart = Cart.create()
            |> Cart.add(product)
    refute Cart.empty?(cart)
  end
  test "When the only product is removed from the cart, the cart becomes empty" do
    product = "chocolate"
    cart = Cart.create()
            |> Cart.add(product)
            |> Cart.remove(product)
    assert Cart.empty?(cart)
  end
  test "When two different products are put into the cart then the cart contains them both" do
    product1 = "milk"
    product2 = "nuts"
    cart = Cart.create()
            |> Cart.add(product1)
            |> Cart.add(product2)

    assert Cart.contains?(cart, product1)
    assert Cart.contains?(cart, product2)
  end
  test "When you count products in an empty cart, the product count is 0" do
    cart = Cart.create()
    assert Cart.count(cart) == 0
  end
  test "When you count products in a cart containing a single product, the product count is 1" do
    product = "waffles"
    cart = Cart.create()
            |> Cart.add(product)
    assert Cart.count(cart) == 1
  end
  test "When two different products are put into the cart after removing one of them the other one stays in the cart" do
    product1 = "milk"
    product2 = "nuts"
    cart = Cart.create()
           |> Cart.add(product1)
           |> Cart.add(product2)
           |> Cart.remove(product2)

    assert Cart.contains?(cart, product1)
    refute Cart.contains?(cart, product2)
  end
end
