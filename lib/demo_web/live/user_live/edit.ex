defmodule DemoWeb.UserLive.Edit do
  use Phoenix.LiveView

  alias DemoWeb.UserLive
  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    socket = assign(socket, %{count: 0, user: user, changeset: changeset})
    {:noreply, socket}
  end

  def render(assigns), do: DemoWeb.UserView.render("edit.html", assigns)

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns.user
      |> Demo.Accounts.change_user(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        {:stop,
         socket
         |> put_flash(:info, "User updated successfully.")
         |> redirect(to: Routes.live_path(socket, UserLive.Show, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
