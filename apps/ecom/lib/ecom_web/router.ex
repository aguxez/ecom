defmodule EcomWeb.Router do
  use EcomWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authorized do
    plug Ecom.Auth.Pipeline
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

    get("/secret", PageController, :secret)

    # Admin panel
    resources("/site_settings", AdminController, only: [:index])

    # User account
    post("/account/:id", AccountController, :update)
    resources("/account", AccountController, only: [:index, :update])
  end
end
