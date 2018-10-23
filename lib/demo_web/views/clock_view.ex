defmodule DemoWeb.ClockView do
  use Phoenix.LiveView
  import Calendar.Strftime

  def render(assigns) do
    ~E"""
    <div>
      <h1>It's time for ElixirConf!</h1>
      <h2>It's <%= strftime!(@date, "%r") %></h2>
    </div>
    """
  end

  def prepare(_, socket) do
    {:ok, put_date(socket)}
  end

  def init(socket) do
    :timer.send_interval(1000, self(), :tick)
    {:ok, socket}
  end

  def handle_info(:tick, socket), do: {:noreply, put_date(socket)}

  defp put_date(socket) do
    assign(socket, date: :calendar.local_time())
  end
end
