defmodule EcomWeb.Router do
  use EcomWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EcomWeb.Plugs.Locale
    plug EcomWeb.Plugs.CartPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authorized do
    plug EcomWeb.Auth.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", EcomWeb do
    pipe_through [:browser, :authorized]

    get("/", PageController, :index)

    # Sessions
    resources("/sessions", SessionController, only: [:new, :create, :delete])

    # Registrations
    resources("/register", RegistrationController, only: [:new, :create])
  end

  scope "/", EcomWeb do
    pipe_through [:browser, :authorized, :ensure_auth]

    # User account
    post("/account/:id", AccountController, :update)
    resources("/account", AccountController, only: [:index, :update])
    resources("/payments", PaymentsController, only: [:index, :create])
  end

  scope "/site_settings", EcomWeb do
    pipe_through [:browser, :authorized, :ensure_auth]

    # Admin panel
    resources("/", AdminController, only: [:index])

    get("/product/new", AdminController, :new_product)
    get("/product/:id/edit", AdminController, :edit_product)
    post("/product", AdminController, :create_product)
    put("/product/:id", AdminController, :update_product)
    delete("/product/:id", AdminController, :delete_product)
  end

  scope "/pub", EcomWeb do
    # Everything that needs to be shown to the public will be on '/pub'
    pipe_through [:browser, :authorized]

    # Root goes to "/product"
    # 'EcomWeb.Plugs.Redirect'
    get("/", Plugs.Redirect, to: "/pub/product")

    # Products
    resources("/product", ProductController, only: [:index, :show])
    resources("/cart", CartController, only: [:index])
    get("/cart/process_cart", CartController, :process_cart)
    post("/cart", CartController, :add_to_cart)
    delete("/cart/:id", CartController, :delete_product)
  end
end
