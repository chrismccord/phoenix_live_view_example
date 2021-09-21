defmodule DemoWeb.UserLive.Show do
  use DemoWeb, :live_view

  alias Demo.Accounts
  alias Phoenix.LiveView.Socket

  def render(assigns) do
    ~H"""
    <h2>Show User</h2>
    <ul>
      <li><b>Username:</b> <%= @user.username %></li>
      <li><b>Email:</b> <%= @user.email %></li>
      <li><b>Phone:</b> <%= @user.phone_number %></li>
    </ul>
    <span><%= live_redirect "Edit", to: Routes.user_edit_path(@socket, :edit, @user) %></span>
    <span><%= live_redirect "Back", to: Routes.user_index_path(@socket, :index) %></span>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    if connected?(socket), do: Demo.Accounts.subscribe(id)
    {:noreply, socket |> assign(id: id) |> fetch()}
  end

  defp fetch(%Socket{assigns: %{id: id}} = socket) do
    assign(socket, user: Accounts.get_user!(id))
  end

  def handle_info({Accounts, [:user, :updated], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({Accounts, [:user, :deleted], _}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "This user has been deleted from the system")
     |> redirect(to: Routes.user_index_path(socket, :index))}
  end
end
