defmodule DemoWeb.CountersLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <%= inspect(@counters) %>
    <button phx-click="shuffle">shufftle</button>
    <%= for {{id, count}, index} <- Enum.with_index(@counters) do %>
      <%= if index == 0 do %>
        <blockquote>
          <div>
            <pre>
              <%= id %><%= live_render(@socket, DemoWeb.CounterLive, id: "counter-#{id}", session: %{val: count}) %>
            <pre>
          <div>
        </blockquote>
      <% else %>
        <%= id %><%= live_render(@socket, DemoWeb.CounterLive, id: "counter-#{id}", session: %{val: count}) %>
      <% end %>
    <% end %>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, counters: [{1, 1}, {2, 2}, {3, 3}])}
  end

  def handle_event("shuffle", _, socket) do
    {:noreply, assign(socket, counters: IO.inspect(Enum.shuffle(socket.assigns.counters)))}
  end
end

defmodule DemoWeb.CounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h1 phx-click="boom">The count is: <span id="val" phx-hook="Count" phx-update="ignore"><%= @val %></a></h1>
      <%= @val %>
      <button phx-click="boom" class="alert-danger">BOOM</button>
      <button phx-click="dec">-</button>
      <button phx-click="inc" phx-debounce="1000">+</button>
    </div>
    """
  end

  def mount(session, socket) do
    {:ok, assign(socket, :val, session[:val] || 0)}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end
end
