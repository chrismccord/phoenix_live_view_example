defmodule TurboWeb.PageController do
  use TurboWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
