defmodule DemoWeb.User.IndexView do
  use Phoenix.LiveView

  alias Demo.Accounts
  alias DemoWeb.UserView

  def init(_params, socket) do
    Demo.Accounts.subscribe()
    {:ok, fetch(socket)}
  end

  def render(assigns), do: UserView.render("index.html", assigns)

  defp fetch(socket) do
    assign(socket, %{
      users: Accounts.list_users(),
    })
  end

  def handle_info({Accounts, [:user | _], _}, socket) do
    {:ok, fetch(socket)}
  end

  def handle_event("delete_user", _, id, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:ok, socket}
  end
end