defmodule DemoWeb.BoomView do
  use Phoenix.LiveView

  def radio_tag(name, field_val, checked_val) do
    ~E"""
    <input type="radio"
      name="<%= name %>"
      value="<%= field_val %>"
    <%= if field_val == checked_val, do: "checked" %> />
    """
  end

  def render(assigns) do
    ~E"""
    <form phx-change="update">
      <input type="range" min="10" max="630" name="width" value="<%= @width %>" />
      <%= @width %>px
      <fieldset>
        White <%= radio_tag(:bg, "white", @bg) %>
        Black <%= radio_tag(:bg, "black", @bg) %>
        Blue <%= radio_tag(:bg, "blue", @bg) %>
      </fieldset>
    </form>
    <button phx-click="boom">boom</button>
    <br/>
    <img src="/images/phx.png" width="<%= @width %>" style="background: <%= @bg %>;" />
    """
  end

  def authorize(_params, _session, socket) do
    {:ok, assign(socket, width: 100, bg: "white")}
  end

  def handle_event("update", _, %{"width" => width, "bg" => bg}, socket) do
    {:noreply, assign(socket, width: String.to_integer(width), bg: bg)}
  end
end
