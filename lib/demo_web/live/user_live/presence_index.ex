defmodule DemoWeb.UserLive.PresenceIndex do
  use Phoenix.LiveView

  alias Demo.Accounts
  alias DemoWeb.{UserView, Presence}
  alias Phoenix.Socket.Broadcast
  alias DemoWeb.Router.Helpers, as: Routes

  def mount(_session, socket) do
    {:ok, socket}
  end

  def render(assigns), do: UserView.render("index.html", assigns)

  def handle_params(%{"name" => name}, _uri, socket) do
    if connected?(socket), do: Demo.Accounts.subscribe()
    Phoenix.PubSub.subscribe(Demo.PubSub, "users")
    Presence.track(self(), "users", name, %{})
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, %{
      users: Accounts.list_users(1, 10),
      page: 1,
      online_users: DemoWeb.Presence.list("users")
    })
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({Accounts, [:user | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("keydown", %{"code" => "ArrowLeft"}, socket) do
    {:noreply, go_page(socket, socket.assigns.page - 1)}
  end
  def handle_event("keydown", %{"code" => "ArrowRight"}, socket) do
    {:noreply, go_page(socket, socket.assigns.page + 1)}
  end
  def handle_event("keydown", _, socket), do: {:noreply, socket}

  defp go_page(socket, page) when page > 0 do
    live_redirect(socket, to: Routes.live_path(socket, __MODULE__, page))
  end
  defp go_page(socket, page), do: socket

  def handle_event("delete_user", id, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:noreply, socket}
  end
end
