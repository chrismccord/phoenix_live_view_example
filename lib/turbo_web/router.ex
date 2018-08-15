defmodule TurboWeb.Router do
  use TurboWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {TurboWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser

    get "/users", Phoenix.TurboView, TurboWeb.UserIndexView, as: :user
    get "/users/new", Phoenix.TurboView, TurboWeb.UserNewView, as: :user
    get "/users/:id", Phoenix.TurboView, TurboWeb.UserShowView, as: :user
    get "/users/:id/edit", Phoenix.TurboView, TurboWeb.UserEditView, as: :user
  end

  scope "/", TurboWeb do
    pipe_through :browser # Use the default browser stack

    # resources "/users", UserController
    get "/", PageController, :index
    get "/testing", PageController, :index
    get "/products/:foo", ProductController, :show
    get "/products/:foo/:bar", ProductController, :show
    get "/products/:foo/:bar/:rebar", ProductController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", TurboWeb do
  #   pipe_through :api
  # end
end
