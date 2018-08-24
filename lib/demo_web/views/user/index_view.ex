defmodule DemoWeb.User.IndexView do
  use Phoenix.LiveView

  alias Demo.Accounts
  alias DemoWeb.{UserView, Presence}
  alias Phoenix.Socket.Broadcast

  def init(socket) do
    Demo.Accounts.subscribe()
    :timer.send_interval(1000, self(), :count)
    Phoenix.PubSub.subscribe(Demo.PubSub, "users")
    Presence.track(self(), "users", socket.assigns.conn.params["name"] || "anon", %{})
    {:ok, fetch(assign(socket, count: 0))}
  end

  def render(assigns), do: UserView.render("index.html", assigns)

  defp fetch(socket) do
    assign(socket, %{
      users: Accounts.list_users(),
      online_users: IO.inspect(DemoWeb.Presence.list("users"))
    })
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket), do: {:ok, fetch(socket)}

  def handle_info(:count, socket) do
    {:ok, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_info({Accounts, :user_updated, _}, socket), do: {:ok, fetch(socket)}
  def handle_info({Accounts, :user_created, _}, socket), do: {:ok, fetch(socket)}
  def handle_info({Accounts, :user_deleted, _}, socket), do: {:ok, fetch(socket)}

  def handle_event("delete_user", _, id, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:ok, socket}
  end
end
