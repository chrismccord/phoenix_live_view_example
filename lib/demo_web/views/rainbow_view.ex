defmodule DemoWeb.RainbowView do
  use Phoenix.LiveView
  use Phoenix.HTML

  @interval (1000 / 60)

  def render(assigns) do
    ~E"""
    <h1>Silky Smooth SSR</h1>
    <h3>Fast enough to power animations <em>[on the server]</em> at <%= @fps %>FPS</h3>
    <div class="animated-sin-wave" phx-click="switch">
      <%= render_rainbow(assigns) %>
    </div>
    <br/>
    <h3>
      The above animation is <%= @bar_count %> <%= "<div>" %> tags.
      <br/>
      No SVG, no CSS transitions/animations.
      It's all powered by <em>Phoenix</em> which does a full re-render every frame.
    </h3>
    """
  end
  defp render_rainbow(%{count: count, bar_count: bar_count}) do
    bar_width = 100 / bar_count

    for i <- 0..bar_count do
      translate_y = :math.sin(count / 10 + i / 5) * 100 * 0.5
      hue = rem(trunc(360 / bar_count * i - count), 360)
      color = "hsl(#{hue},95%,55%)"
      rotation = rem(trunc(count + i), 360)
      bar_x = bar_width * i
      style = "width: #{bar_width}%; left: #{bar_x}%; transform: scale(0.8,.5) translateY(#{translate_y}%) rotate(#{rotation}deg); background-color: #{color};"
      ~E|<div class="bar" style="<%= style %>"></div>|
    end
  end

  def init(_params, socket) do
    inner_window_width = 1200
    {:ok, _} = :timer.send_interval(trunc(@interval), self(), :next_frame) # 60 FPS

    {:ok, assign(socket,
      fps: trunc(Float.ceil(1000 / @interval)),
      interval: @interval,
      step: 0.5,
      count: 0,
      inner_window_width: inner_window_width,
      bar_count: Enum.min([200, trunc(:math.floor(inner_window_width / 15))])
    )}
  end

  def handle_info(:next_frame, socket) do
    %{count: count, step: step} = socket.assigns
    {:ok, assign(socket, count: count + step)}
  end

  def handle_event("switch", _id, _val, %{assigns: assigns} = socket) do
    {:ok, assign(socket, step: assigns.step * -1)}
  end
end
