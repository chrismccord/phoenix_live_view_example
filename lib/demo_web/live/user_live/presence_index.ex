defmodule DemoWeb.UserLive.PresenceIndex do
  use Phoenix.LiveView

  alias Demo.Accounts
  alias DemoWeb.{UserView, Presence}
  alias Phoenix.Socket.Broadcast

  def mount(%{"name" => name}, _session, socket) do
    Demo.Accounts.subscribe()
    Phoenix.PubSub.subscribe(Demo.PubSub, "users")
    Presence.track(self(), "users", name, %{})
    {:ok, assign(socket, page: 1, per_page: 5)}
  end

  def render(assigns), do: UserView.render("index.html", assigns)

  def handle_params(%{"name" => name}, _uri, socket) do
    if connected?(socket), do: Demo.Accounts.subscribe()
    Phoenix.PubSub.subscribe(Demo.PubSub, "users")
    Presence.track(self(), "users", name, %{})
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    %{page: page, per_page: per_page} = socket.assigns
    users = Accounts.list_users(page, per_page)
    online_users = DemoWeb.Presence.list("users")
    assign(socket, page: 1, per_page: 5, users: users, online_users: online_users)
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({Accounts, [:user | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("delete_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:noreply, socket}
  end
end
