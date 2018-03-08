defmodule Ecom.Interfaces.AssocWorker do
  @moduledoc false

  alias Ecom.AssocWorker

  defdelegate add(module, attrs), to: AssocWorker
end
