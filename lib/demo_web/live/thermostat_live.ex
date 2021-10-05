defmodule DemoWeb.TitleComponent do
  use DemoWeb, :live_component

  import Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <span phx-click={push("toggle-mode", page_loading: true, target: ".thermostat") |> toggle(to: "#weather", in: "fade-in-scale", out: "fade-out-scale")}><%= @title%></span>
    """
  end
end

defmodule DemoWeb.ThermostatLive do
  use DemoWeb, :live_view


  def render(assigns) do
    import Phoenix.LiveView.JS

    ~H"""
    <div phx-handle-shake={transition("shake", time: 1000)}>
      <div class="thermostat">
        <div class={"bar #{@mode}"}>
          <a href="#" phx-click={push("toggle-mode", page_loading: true) |> toggle(to: "#weather", in: "fade-in-scale", out: "fade-out-scale")}>
            <%= @mode %>
          </a>
          <span><%= NimbleStrftime.format(@time, "%H:%M:%S") %></span>
        </div>
        <div class="controls">
          <span class="reading"><%= @val %></span>
          <button phx-click={push("dec") |> add_class("alert-danger", to: ".thermostat")} class="minus">-</button>
          <button phx-click={push("inc") |> remove_class("alert-danger", to: ".thermostat")} class="plus">+</button>
          <span class="weather">
            <%= live_render(@socket, DemoWeb.WeatherLive, id: "weather") %>
          </span>
        </div>

        <%= live_component DemoWeb.TitleComponent, id: "title", title: @mode %>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)
    {:ok, assign(socket, val: 72, mode: :cooling, time: NaiveDateTime.local_now())}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, time: NaiveDateTime.local_now())}
  end

  def handle_event("inc", _, socket) do
    if socket.assigns.val >= 75, do: raise("boom")
    {:noreply, socket |> push_event("shake", %{val: socket.assigns.val}) |> update(:val, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

  def handle_event("toggle-mode", _, socket) do
    Process.sleep(2000)
    {:noreply,
     update(socket, :mode, fn
       :cooling -> :heating
       :heating -> :cooling
     end)}
  end
end
