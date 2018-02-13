defmodule EcomWeb.ErrorViewTest do
  use EcomWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(EcomWeb.ErrorView, "404.html", []) ==
           "Página no encontrada"
  end

  test "render 500.html" do
    assert render_to_string(EcomWeb.ErrorView, "500.html", []) ==
           "Error interno del servidor"
  end

  test "render any other" do
    assert render_to_string(EcomWeb.ErrorView, "505.html", []) ==
           "Error interno del servidor"
  end
end
