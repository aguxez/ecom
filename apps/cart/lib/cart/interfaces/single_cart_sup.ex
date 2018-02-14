defmodule Cart.Interfaces.SingleCartSup do
  @moduledoc false

  alias Cart.Sup.SingleCartSup

  defdelegate start_child(name),      to: SingleCartSup
end
