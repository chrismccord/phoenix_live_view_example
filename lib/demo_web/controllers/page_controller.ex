defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  def index(conn, _params) do
    IO.inspect(conn.query_params)
    render conn, "index.html"
  end
end
