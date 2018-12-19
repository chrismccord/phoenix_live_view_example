defmodule DemoWeb.ImageView do
  use Phoenix.LiveView

  def radio_tag(assigns) do
    ~L"""
    <input type="radio" name="<%= @name %>" value="<%= @value %>"
      <%= if @value == @checked, do: "checked" %> />
    """
  end

  def render(assigns) do
    ~L"""
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
    <img src="/images/phx.png" width="<%= @width %>" style="background: <%= @bg %>;" />
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, width: 100, bg: "white")}
  end

  def handle_event("update", %{"width" => width, "bg" => bg}, socket) do
    {:noreply, assign(socket, width: String.to_integer(width), bg: bg)}
  end
end
