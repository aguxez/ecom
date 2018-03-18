defmodule EcomWeb.SEO.Defaults do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def title(_, _assigns), do: "Ecom | Ecommerce template | Elixir"

      def description(_, _assigns) do
        """
        Get started quickly with an already made template for an ecommerce using Elixir and Phoenix.
        """
      end

      def meta(_, _), do: "Default meta"

      defoverridable [title: 2, meta: 2, description: 2]
    end
  end
end
