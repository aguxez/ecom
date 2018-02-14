defmodule CartTest do
  use ExUnit.Case
  doctest Cart

  test "greets the world" do
    assert Cart.hello() == :world
  end
end
