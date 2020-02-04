defmodule DemoWeb.RainbowLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  @fps 60
  @inner_window_width 1200

  def render(assigns) do
    ~L"""
    <h1>Silky Smooth SSR</h1>
    <h3>Fast enough to power animations <em>[on the server]</em> at <%= @fps %>FPS</h3>
    <form phx-change="update_fps">
      <input type="range" min="1" max="100" value="<%= @fps %>" name="fps"/>
    </form>
    <div class="animated-sin-wave" phx-click="switch" style="background: <%= @bg %>;">
      <%= for bar <- @bars do %>
        <div class="bar" id="<%= bar.id %>" style="width: <%= bar.width %>%; left: <%= bar.x %>%; transform: scale(0.8,.5) translateY(<%= bar.translate_y %>%) rotate(<%= bar.rotation %>deg); background-color: hsl(<%= bar.hue %>,95%,55%);">
        </div>
      <% end %>
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

  defp assign_bars(socket) do
    bar_count = socket.assigns.bar_count
    count = socket.assigns.count
    bar_width = 100 / bar_count

    bars =
      for i <- 0..bar_count do
        %{
          id: "bar#{System.unique_integer([:positive])}",
          x: bar_width * i,
          translate_y: :math.sin(count / 10 + i / 5) * 100 * 0.5,
          rotation: rem(trunc(count + i), 360),
          width: bar_width,
          hue: rem(trunc(360 / bar_count * i - count), 360)
        }
      end

    assign(socket, bars: bars)
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(%{
        bg: "white",
        fps: @fps,
        step: 0.5,
        count: 0,
        inner_window_width: @inner_window_width,
        bar_count: Enum.min([200, trunc(:math.floor(@inner_window_width / 15))])
      })
      |> assign_bars()

    if connected?(socket), do: schedule_next_frame(socket)

    {:ok, socket}
  end

  defp schedule_next_frame(socket) do
    Process.send_after(self(), :next_frame, trunc(1000 / socket.assigns.fps))
  end

  def handle_info(:next_frame, socket) do
    schedule_next_frame(socket)
    %{count: count, step: step} = socket.assigns

    socket =
      socket
      |> assign(count: count + step)
      |> assign_bars()

    {:noreply, socket}
  end

  def handle_event("switch", _val, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, step: assigns.step * -1)}
  end

  def handle_event("update_fps", %{"fps" => fps}, socket) do
    fps = String.to_integer(fps)
    {:noreply, assign(socket, :fps, fps)}
  end
end
