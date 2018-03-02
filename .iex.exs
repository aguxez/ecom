import EcomWeb.Helpers

alias Cart.{SingleCart, SingleCartSup}
alias Ecom.Accounts
alias Ecom.Accounts.{Product, User}
alias Ecom.Repo

conn = %Plug.Conn{}
u = Accounts.get_user!(1)
