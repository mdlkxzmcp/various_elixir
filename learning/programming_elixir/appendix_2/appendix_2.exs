# Type Specifications and Type Checking

## Types and Structures

defmodule LineItem do
  defstruct sku: "", quantity: 1
  @type t :: %LineItem{sku: String.t, quantity: integer}
end

@type variant(type_name, type) :: { :variant, type_name, type }
@spec create_string_tuple(:string, String.t) :: variant(:string, String.t)
