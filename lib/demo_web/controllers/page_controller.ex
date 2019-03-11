defmodule DemoWeb.PageController do
  use DemoWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def snake(conn, _) do
    conn
    |> put_layout(:game)
    |> LiveView.live_render(DemoWeb.SnakeView)
  end

  def thermostat(conn, _) do
    conn
    |> put_layout(:bare)
    |> LiveView.live_render(DemoWeb.ThermostatView)
  end

  def pacman(conn, _) do
    LiveView.live_render(conn, DemoWeb.PacmanView)
  end

  def keyboarding(conn, _) do
    LiveView.live_render(conn, DemoWeb.KeyboardingView)
  end

  def game(conn, _) do
    LiveView.live_render(conn, DemoWeb.GameView)
  end

  def search(conn, _) do
    LiveView.live_render(conn, DemoWeb.SearchView)
  end

  def image(conn, _) do
    LiveView.live_render(conn, DemoWeb.ImageView)
  end

  def rainbow(conn, _) do
    LiveView.live_render(conn, DemoWeb.RainbowView)
  end

  def clock(conn, _) do
    LiveView.live_render(conn, DemoWeb.ClockView)
  end

  def count(conn, _) do
    LiveView.live_render(conn, DemoWeb.CounterView, session: %{params: conn.params})
  end

  def counter(conn, _) do
    LiveView.live_render(conn, DemoWeb.CounterView)
  end
end
