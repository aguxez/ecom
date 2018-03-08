defmodule Ecom.AssocWorker do
  @moduledoc false

  alias Ecom.Repo

  def add(module, attrs) do
    module
    |> struct()
    |> module.changeset(attrs)
    |> Repo.insert()
  end
end
