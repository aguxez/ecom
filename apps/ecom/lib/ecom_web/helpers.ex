defmodule EcomWeb.Helpers do
  @moduledoc false

  # Basic
  def current_user(conn, "basic") do
    user = Ecom.Guardian.Plug.current_resource(conn)

    unless user == nil do
      # 'overall' is just a key to hide the is_admin field from React props.
      %{username: user.username, id: user.id, overall: user.is_admin}
    end
  end

  def current_user(conn, "everything") do
    user = Ecom.Guardian.Plug.current_resource(conn)

    unless user == nil, do: user
  end

  # Define 'fields' to get from 'user'
  def current_user(conn, fields) do
    user = Ecom.Guardian.Plug.current_resource(conn)

    unless user == nil do
      user
      |> Map.take(fields)
      |> evaluate_admin_field(user)
    end
  end

  defp evaluate_admin_field(map, user) do
    case Map.get(map, :is_admin) do
      nil ->
        map
      _ ->
        map
        |> Map.drop([:is_admin])
        |> Map.put(:overall, user.is_admin)
    end
  end

  def get_csrf_token do
    Plug.CSRFProtection.get_csrf_token()
  end
end
