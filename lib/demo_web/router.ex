defmodule DemoWeb.Router do
  use DemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {DemoWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser

    get "/search", Phoenix.LiveView, DemoWeb.SearchView
    get "/boom", Phoenix.LiveView, DemoWeb.BoomView
    get "/rainbow", Phoenix.LiveView, DemoWeb.RainbowView
    get "/clock", Phoenix.LiveView, DemoWeb.ClockView
    get "/count", DemoWeb.PageController, :count
    get "/counter", Phoenix.LiveView, DemoWeb.CounterView
    get "/presence_users", Phoenix.LiveView, DemoWeb.User.PresenceIndexView, as: :user
    get "/users", Phoenix.LiveView, DemoWeb.User.IndexView, as: :user
    get "/users/new", Phoenix.LiveView, DemoWeb.User.NewView, as: :user
    get "/users/:id", Phoenix.LiveView, DemoWeb.User.ShowView, as: :user
    get "/users/:id/edit", Phoenix.LiveView, DemoWeb.User.EditView, as: :user
  end

  scope "/", DemoWeb do
    pipe_through :browser # Use the default browser stack

    # resources "/users", UserController
    get "/", PageController, :index
    get "/testing", PageController, :index
    get "/products/:foo", ProductController, :show
    get "/products/:foo/:bar", ProductController, :show
    get "/products/:foo/:bar/:rebar", ProductController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", DemoWeb do
  #   pipe_through :api
  # end
end
