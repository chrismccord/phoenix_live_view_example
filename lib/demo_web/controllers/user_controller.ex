defmodule DemoWeb.UserController do
  use DemoWeb, :controller

  alias Demo.Accounts
  alias Demo.Accounts.User
  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.live_render(conn, DemoWeb.User.IndexView)
  end

  def new(conn, _params) do
    LiveView.live_render(conn, DemoWeb.User.NewView)
  end

  def show(conn, params) do
    LiveView.live_render(conn, DemoWeb.User.ShowView, session: %{params: params})
  end

  def edit(conn, params) do
    LiveView.live_render(conn, DemoWeb.User.EditView, session: %{params: params})
  end

  def presence_users(conn, params) do
    LiveView.live_render(conn, DemoWeb.User.PresenceIndexView, session: %{params: params})
  end
end
