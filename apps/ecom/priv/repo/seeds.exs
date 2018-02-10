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

alias Ecom.Accounts.User
alias Ecom.Repo

attrs = %{
  email: "diazmiiguel@gmail.com",
  username: "aguxez",
  password: "m2481369",
  password_confirmation: "m2481369",
}

%User{}
|> User.changeset(attrs)
|> Repo.insert!()
