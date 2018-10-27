defmodule DemoWeb.User.EditView do
  use Phoenix.LiveView

  alias DemoWeb.UserView
  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts

  def authorize(%{"id" => id}, _session, socket) do
    user = Accounts.get_user!(id)

    {:ok, assign(socket, %{
      count: 0,
      user: user,
      changeset: Accounts.change_user(user),
    })}
  end

  def render(assigns), do: UserView.render("edit.html", assigns)

  def handle_event("validate", _id, %{"user" => params}, socket) do
    changeset =
      socket.assigns.user
      |> Demo.Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", _id, %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        socket
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(DemoWeb.Endpoint, DemoWeb.User.ShowView, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
