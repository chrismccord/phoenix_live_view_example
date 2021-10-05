defmodule DemoWeb.ModalComponent do
  use DemoWeb, :live_component

  @impl true

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class="phx-modal"
      phx-window-keydown={JS.dispatch("click", to: "#close")}
      phx-key="escape"
      phx-page-loading>

      <div class="phx-modal-content fade-in"
        phx-click-away={JS.dispatch("click", to: "#close")}>
        <%= live_patch raw("&times;"),
          to: @return_to,
          id: "close",
          phx_click: JS.transition("fade-out", 200, to: ".phx-modal-content"),
          class: "phx-modal-close" %>
        <%= live_component @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
