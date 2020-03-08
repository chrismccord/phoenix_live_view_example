defmodule DemoWeb.Router do
  use DemoWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_live_layout, {DemoWeb.LayoutView, :app}
  end

  pipeline :bare do
    plug :put_live_layout, {DemoWeb.LayoutView, :bare}
  end

  pipeline :game do
    plug :put_live_layout, {DemoWeb.LayoutView, :game}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # If enabling the LiveDashboard in prod,
  # put it behind proper authentication.
  if Mix.env() == :dev do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: DemoWeb.Telemetry
    end
  end

  scope "/", DemoWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/thermostat", ThermostatLive
    live "/search", SearchLive
    live "/clock", ClockLive
    live "/image", ImageLive
    live "/pacman", PacmanLive
    live "/rainbow", RainbowLive
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

  scope "/", DemoWeb do
    pipe_through [:browser, :game]

    live "/snake", SnakeLive
  end


  scope "/", DemoWeb do
    pipe_through [:browser, :bare]

    live "/users-live-layout", UserLive.IndexNav
    live "/users-live-layout/page/:page", UserLive.IndexNav
  end
end
