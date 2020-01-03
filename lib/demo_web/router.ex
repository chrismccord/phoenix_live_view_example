defmodule DemoWeb.Router do
  use DemoWeb, :router
  import Phoenix.LiveView.Router

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

  scope "/", DemoWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/thermostat", ThermostatLive
    get "/snake", PageController, :snake
    live "/search", SearchLive
    live "/clock", ClockLive
    live "/image", ImageLive
    live "/pacman", PacmanLive
    live "/life", LifeLive
    live "/rainbow", RainbowLive
    live "/counter", CounterLive
    live "/counters", CountersLive
    live "/top", TopLive
    live "/presence_users/:name", UserLive.PresenceIndex

    live "/users/page/:page", UserLive.Index
    live "/users", UserLive.Index
    live "/users-scroll", UserLive.IndexManualScroll
    live "/users-auto-scroll", UserLive.IndexAutoScroll

    live "/users/new", UserLive.New
    live "/users/:id", UserLive.Show
    live "/users/:id/edit", UserLive.Edit

    resources "/plain/users", UserController
  end
end
