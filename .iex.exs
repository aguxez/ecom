import EcomWeb.Helpers

alias Cart.{SingleCart, SingleCartSup}
alias Ecom.{Repo, ProductValues, Accounts}
alias Ecom.Accounts.{Product, User}

conn = %Plug.Conn{}
u = Accounts.get_user!(1)
cart = Accounts.get_cart!(u.cart.id)

ProductValues.start_link(u.id)
