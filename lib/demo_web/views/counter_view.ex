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

  def upgrade(_conn, unsigned_params) do
    {:ok, %{val: String.to_integer(unsigned_params["val"] || "0")}}
  end

  def prepare(%{val: val}, socket) do
    {:ok, assign(socket, :val, val + 1)}
  end

  def init(socket) do
    {:ok, socket}
  end

  def handle_event("inc", _, _, socket) do
    {:noreply, sync_params(update(socket, :val, &(&1 + 1)))}
  end

  def handle_event("dec", _, _, socket) do
    {:noreply, sync_params(update(socket, :val, &(&1 - 1)))}
  end

  defp sync_params(socket) do
    push_params(socket, val: socket.assigns.val)
  end
end
