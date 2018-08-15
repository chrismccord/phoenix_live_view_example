defmodule TurboWeb.UserShowView do
  use TurboWeb, :view
  use Phoenix.TurboView

  alias Turbo.Accounts

  def init(%{conn: %{params: %{"id" => id}}} = assigns) do
    Turbo.Accounts.subscribe(id)
    {:ok, fetch(Map.merge(assigns, %{id: id}))}
  end

  defp fetch(%{id: id} = assigns) do
    Map.merge(assigns, %{user: Accounts.get_user!(id)})
  end

  defp render_template("template.html", assigns) do
    ~E|
    <h2>Show User</h2>
    <ul>
      <li><b>Username:</b> <%= @user.username %></li>
      <li><b>Email:</b> <%= @user.email %></li>
      <li><b>State:</b> <%= @user.state %></li>
      <li><b>Country:</b> <%= @user.country %></li>
    </ul>
    <span><%= link "Edit", to: Routes.user_path(@conn, TurboWeb.UserEditView, @user) %></span>
    <span><%= link "Back", to: Routes.user_path(@conn, TurboWeb.UserIndexView) %></span>
    |
  end

  def handle_info({Accounts, :user_updated, _}, state), do: {:ok, fetch(state)}

  def handle_info({Accounts, :user_deleted, _}, state) do
    state
    |> put_flash(:error, "This user has been deleted from the system")
    |> redirect(to: Routes.user_path(state.conn, TurboWeb.UserIndexView))
  end
end
