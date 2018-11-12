defmodule DemoWeb.GameView do
  use Phoenix.LiveView

  def render(assigns) do
    ~E"""
    <div phx-keydown="keydown" phx-target="document"></div>
    <%= @pressed %>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, :pressed, "waiting for keypress...")}
  end

  def handle_event("keydown", _, params, socket) do
    {:noreply, assign(socket, :pressed, inspect(params))}
  end
end
