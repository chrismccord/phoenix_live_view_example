defmodule DemoWeb.ImageLive do
  use DemoWeb, :live_view

  def radio_tag(assigns) do
    ~H"""
    <input type="radio" name={@name} value={@value} checked={@value == @checked}/>
    """
  end

  def render(assigns) do
    ~H"""
    <div style={"margin-left: #{@depth * 50}px;"}>
      <form phx-change="update">
        <input type="range" min="10" max="630" name="width" value={@width} />
        <%= @width %>px
        <fieldset>
          White <.radio_tag name={:bg} value="white" checked={@bg}/>
          Black <.radio_tag name={:bg} value="black" checked={@bg}/>
          Blue <.radio_tag name={:bg} value="blue" checked={@bg}/>
        </fieldset>
      </form>
      <br/>
      <img phx-click="boom"
        src={Routes.static_path(DemoWeb.Endpoint, "/images/phoenix.png")}
        width={@width} style={"background: #{@bg};"}/>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, width: 100, bg: "white", depth: 0, max_depth: 0)}
  end

  def handle_event("update", %{"width" => width, "bg" => bg}, socket) do
    {:noreply, assign(socket, width: String.to_integer(width), bg: bg)}
  end
end
