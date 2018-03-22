defmodule EcomWeb.Router do
  use EcomWeb, :router

  @csp """
  default-src 'self'; \
  script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.paypalobjects.com https://www.paypal.com https://use.fontawesome.com; \
  style-src 'self' 'unsafe-inline' 'unsafe-eval'; \
  connect-src ws://localhost:4000/; \
  img-src 'self' 'unsafe-inline' https://www.sandbox.paypal.com/; \
  """

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers, %{"content-security-policy" => @csp})
    plug(EcomWeb.Plugs.Locale)
    plug(EcomWeb.Plugs.CartPlug)
    plug(EcomWeb.Plugs.PayID)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authorized do
    plug(EcomWeb.Auth.Pipeline)
    plug(:put_user_auth_token)
  end

  defp put_user_auth_token(conn, _) do
    if curr_user = current_user(conn) do
      token = Phoenix.Token.sign(conn, "auth_salt", curr_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  scope "/", EcomWeb do
    pipe_through([:browser, :authorized])

    get("/", PageController, :index)

    # Sessions
    resources("/sessions", SessionController, only: [:new, :create, :delete])

    # Registrations
    resources("/register", RegistrationController, only: [:new, :create])
  end

  scope "/", EcomWeb do
    pipe_through([:browser, :authorized, :ensure_auth])

    # User account
    post("/account/:id", AccountController, :update)
    resources("/account", AccountController, only: [:index, :update])

    # Payments
    resources("/payments", PaymentsController, only: [:index, :create])
    get("/payments/processed", PaymentsController, :processed)
    get("/payments/pending", PaymentsController, :pending)
    get("/payments/failure", PaymentsController, :failure)
    post("/payments/update_personal", PaymentsController, :update_personal_information)
    put("/payments/update_personal", PaymentsController, :update_personal_information)
  end

  scope "/mpago", EcomWeb do
    pipe_through([:api])

    post("/notify", PaymentsNotifyController, :payment)
  end

  scope "/site_settings", EcomWeb do
    pipe_through([:browser, :authorized, :ensure_auth])

    # Admin panel
    resources("/", AdminController, only: [:index])

    get("/product/new", AdminController, :new_product)
    get("/product/:id/edit", AdminController, :edit_product)
    post("/product", AdminController, :create_product)
    put("/product/:id", AdminController, :update_product)
    delete("/product/:id", AdminController, :delete_product)

    get("/orders/change_status", OrdersController, :change_status)
    resources("/orders", OrdersController, only: [:index, :show])

    resources("/category", CategoryController, only: [:new, :create])
  end

  scope "/pub", EcomWeb do
    # Everything that needs to be shown to the public will be on '/pub'
    pipe_through([:browser, :authorized])

    # Root goes to "/product"
    # 'EcomWeb.Plugs.Redirect'
    get("/", Plugs.Redirect, to: "/pub/product")

    # Products
    resources("/product", ProductController, only: [:index, :show])
    resources("/cart", CartController, only: [:index])
    get("/cart/process_cart", CartController, :process_cart)
    post("/cart", CartController, :add_to_cart)
    delete("/cart/:id", CartController, :delete_product)

    resources("/c", PubCategoryController, only: [:index])
  end
end
