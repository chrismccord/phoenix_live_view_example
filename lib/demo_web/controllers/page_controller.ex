defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def snake(conn, _) do
    conn
    |> put_layout(:game)
    |> LiveView.Controller.live_render(DemoWeb.SnakeLive, session: %{})
  end
end
