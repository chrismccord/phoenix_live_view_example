defmodule DemoWeb.UILive do
  use DemoWeb, :live_view

  alias Phoenix.LiveView.JS

  defp show_tab(tab_name) do
    JS.remove_class("active", to: "#nav-tabs .nav-link, #nav-content .tab-pane")
    |> JS.add_class("show active", to: "##{tab_name}-tab, ##{tab_name}-content")
  end

  def render(assigns) do
    ~H"""
    <link href="//cdn.jsdelivr.net/npm/bootstrap@5.1.1/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <style>
      body{ font-size: 150%; }
    </style>

    <ul class="nav nav-tabs mt-5" id="nav-tabs" role="tablist"
      phx-window-keydown={JS.hide(to: ".tab-pane", transition: "fade-out-scale")}
      phx-key="escape">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="home-tab" type="button" phx-click={show_tab("home")}>
          Home
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="profile-tab" type="button" phx-click={show_tab("profile")}>
          Profile
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="contact-tab" type="button" phx-click={show_tab("contact")}>
          Contact
        </button>
      </li>
    </ul>
    <div class="tab-content" id="nav-content"
      phx-window-keydown={JS.show(to: ".tab-pane", transition: "fade-in-scale")}
      phx-key="enter">
      <div class="tab-pane show active" id="home-content">This is the home tab <%= @count %></div>
      <div class="tab-pane" id="profile-content">This is the profile tab</div>
      <div class="tab-pane" id="contact-content">This is the contact tab</div>
    </div>
    """
  end

  def mount(_, _, socket) do
    if connected?(socket), do: :timer.send_interval(100, :tick)
    {:ok, assign(socket, :count, 0)}
  end

  def handle_info(:tick, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end
end
