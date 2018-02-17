# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ecom.Repo.insert!(%Ecom.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Ecom.Accounts
alias Ecom.Repo

ran = fn ->
  64
  |> :crypto.strong_rand_bytes()
  |> Base.url_encode64()
  |> binary_part(0, 15)
end

attrs = %{
  name: "some#{ran.()}name",
  description: "Some #{ran.()}",
  quantity: Enum.random(1..100_000),
  user_id: 5
}

Enum.each(1..5000, fn _x ->
  Accounts.create_product(attrs)
end)
