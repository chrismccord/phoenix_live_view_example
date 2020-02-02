defmodule DemoWeb.ImageLive do
  use Phoenix.LiveView
  alias DemoWeb.Router.Helpers, as: Routes

  def radio_tag(assigns) do
    assigns = Enum.into(assigns, %{})
    ~L"""
    <input type="radio" name="<%= @name %>" value="<%= @value %>"
      <%= if @value == @checked, do: "checked" %> />
    """
  end

  def render(assigns) do
    ~L"""
    <div style="margin-left: <%= @depth * 50 %>px;">
      <form phx-change="update">
        <input type="range" min="10" max="630" name="width" value="<%= @width %>" />
        <%= @width %>px
        <fieldset>
          White <%= radio_tag(name: :bg, value: "white", checked: @bg) %>
          Black <%= radio_tag(name: :bg, value: "black", checked: @bg) %>
          Blue <%= radio_tag(name: :bg, value: "blue", checked: @bg) %>
        </fieldset>
      </form>
      <br/>
      <img phx-click="boom" src="<%= Routes.static_path(DemoWeb.Endpoint, "/images/phoenix.png") %>" width="<%= @width %>" style="background: <%= @bg %>;" />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    IO.inspect({__MODULE__, connected: connected?(socket), root_pid: socket.root_pid, self: self()})
    {:ok, assign(socket, width: 100, bg: "white", depth: 0, max_depth: 0)}
  end

  def handle_event("update", %{"width" => width, "bg" => bg}, socket) do
    {:noreply, assign(socket, width: String.to_integer(width), bg: bg)}
  end
end
