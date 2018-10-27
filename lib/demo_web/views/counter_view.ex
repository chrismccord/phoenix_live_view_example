defmodule DemoWeb.CounterView do
  use Phoenix.LiveView

  def render(assigns) do
    ~E"""
    <div>
      <h1 phx-click="boom">The count is: <%= @val %></h1>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    """
  end

  def authorize(params, _session, socket) do
    {:ok, assign(socket, :val, params["val"] || 0)}
  end

  def init(socket) do
    {:ok, socket, sync_assigns: [:val]}
  end

  def handle_event("inc", _, _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end
end
