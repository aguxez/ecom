defmodule EcomWeb.ProductView do
  @moduledoc false

  use EcomWeb, :view

  def markdown(body) do
    {:ok, html, []} = Earmark.as_html(body)
    raw(html)
  end
end
