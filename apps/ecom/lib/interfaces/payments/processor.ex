defmodule Ecom.Interfaces.Payments.Processor do
  @moduledoc false

  alias Ecom.Payments.Processor

  defdelegate create_purchase(token, module),       to: Processor
end
