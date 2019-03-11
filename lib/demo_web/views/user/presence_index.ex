defmodule DemoWeb.User.PresenceIndexView do
  use Phoenix.LiveView

  alias Demo.Accounts
  alias DemoWeb.Presence
  alias Phoenix.Socket.Broadcast
  alias DemoWeb.UserView

  def mount(%{params: params}, socket) do
    if connected?(socket) do
      Demo.Accounts.subscribe()
      Phoenix.PubSub.subscribe(Demo.PubSub, "users")
      Presence.track(self(), "users", params["name"] || "anon", %{})
    end
    {:ok, fetch(socket)}
  end

  def render(assigns), do: UserView.render("index.html", assigns)

  defp fetch(socket) do
    assign(socket, %{
      users: Accounts.list_users(),
      online_users: DemoWeb.Presence.list("users")
    })
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({Accounts, [:user | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("delete_user", _, id, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:noreply, socket}
  end
end
