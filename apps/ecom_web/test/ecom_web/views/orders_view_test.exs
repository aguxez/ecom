defmodule EcomWeb.OrdersViewTest do
  @moduledoc false

  use EcomWeb.ConnCase

  alias EcomWeb.OrdersView

  test "value_for returns correct value from Map" do
    value = OrdersView.value_for(12, [%{"12" => 15, "15" => 12}])

    assert value == 15
  end
end
