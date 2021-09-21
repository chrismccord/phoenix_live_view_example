defmodule DemoWeb.ClockLive do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h2>It's <%= NimbleStrftime.format(@date, "%H:%M:%S") %></h2>
      <%= live_render(@socket, DemoWeb.ImageLive, id: "image") %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :tick, 1000)

    {:ok, put_date(socket)}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 1000)
    {:noreply, put_date(socket)}
  end

  def handle_event("nav", _path, socket) do
    {:noreply, socket}
  end

  defp put_date(socket) do
    assign(socket, date: NaiveDateTime.local_now())
  end
end
