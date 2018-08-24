defmodule DemoWeb.Router do
  use DemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {DemoWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser

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

  defp fetch_live_flash(conn, _), do: Phoenix.LiveView.fetch_flash(conn, [])
end
