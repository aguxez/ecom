defmodule Ecom.Interfaces.ProductValues do
  @moduledoc false

  alias Ecom.ProductValues

  defdelegate save_value_for(id, product), to: ProductValues
end
