defmodule EcomWeb.CategoryController do
  @moduledoc """
  Site settings module, this module is handled by Admins, not the one people see on /pub
  """

  use EcomWeb, :controller

  alias Ecom.Interfaces.{Accounts, Worker}

  def new(conn, _params) do
    changeset = Accounts.change_category(%Ecom.Accounts.Category{})
    categories = Enum.map(Accounts.list_categories(), & &1.name)

    render(conn, "new.html", changeset: changeset, categories: categories)
  end

  def create(conn, %{"category" => attrs}) do
    categories = Enum.map(Accounts.list_categories(), & &1.name)

    case Worker.create_category(attrs) do
      {:ok, :created} ->
        conn
        |> put_flash(:success, gettext("Category created!"))
        |> redirect(to: page_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:alert, gettext("We couldn't create your category"))
        |> render("new.html", changeset: changeset, categories: categories)
    end
  end
end
