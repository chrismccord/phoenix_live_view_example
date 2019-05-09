defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def snake(conn, _) do
    conn
    |> put_layout(:game)
    |> live_render(DemoWeb.SnakeLive, session: %{})
  end
end
