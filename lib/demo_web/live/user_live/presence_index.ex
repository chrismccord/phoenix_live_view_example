defmodule DemoWeb.UserLive.PresenceIndex do
  use Phoenix.LiveView

  alias Demo.Accounts
  alias DemoWeb.{UserView, Presence}
  alias Phoenix.Socket.Broadcast

  def mount(%{"name" => name}, _session, socket) do
    Demo.Accounts.subscribe()
    Phoenix.PubSub.subscribe(Demo.PubSub, "users")
    Presence.track(self(), "users", name, %{})
    {:ok, fetch(socket)}
  end

  def render(assigns), do: UserView.render("index.html", assigns)

  defp fetch(socket) do
    assign(socket, %{
      users: Accounts.list_users(1, 10),
      online_users: DemoWeb.Presence.list("users"),
      page: 0
    })
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({Accounts, [:user | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("delete_user", id, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:noreply, socket}
  end
end
