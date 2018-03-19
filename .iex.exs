import EcomWeb.Helpers

alias Cart.{SingleCart, SingleCartSup}
alias Ecom.{Repo, ProductValues, Accounts}
alias Ecom.Accounts.{Product, User, Cart, Category, CartProduct, Order, ProductOrder}

conn = %Plug.Conn{}
u = Accounts.get_user!(1)
cart = Accounts.get_cart!(u.cart.id)
product = Accounts.get_product!(1)

ProductValues.start_link(u.id)
