defmodule DemoWeb.CounterView do
  use Phoenix.LiveView

  def render(assigns) do
    ~E"""
    <div>
      <h1>The count is: <%= @val %></h1>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    """
  end

  def init(_params, socket) do
    {:ok, assign(socket, val: 0)}
  end

  def handle_event("inc", _, _, socket) do
    {:ok, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, _, socket) do
    {:ok, update(socket, :val, &(&1 - 1))}
  end
end
