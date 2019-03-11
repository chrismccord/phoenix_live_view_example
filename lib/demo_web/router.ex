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

  scope "/", DemoWeb do
    pipe_through :browser

    get "/thermostat", PageController, :thermostat
    get "/snake", PageController, :snake
    get "/pacman", PageController, :pacman
    get "/keyboarding", PageController, :keyboarding
    get "/game", PageController, :game
    get "/search", PageController, :search
    get "/image", PageController, :image
    get "/rainbow", PageController, :rainbow
    get "/clock", PageController, :clock
    get "/count", PageController, :count
    get "/counter", PageController, :counter
    get "/presence_users", UserController, :presence_users
    get "/users", UserController, :index
    get "/users/new", UserController, :new
    get "/users/:id", UserController, :show
    get "/users/:id/edit", UserController, :edit
  end
end
