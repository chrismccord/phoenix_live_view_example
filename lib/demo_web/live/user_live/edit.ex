defmodule DemoWeb.UserLive.Edit do
  use Phoenix.LiveView

  alias DemoWeb.UserLive
  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts

  def mount(_session, socket) do
    {:ok, socket}
  end

  def render(assigns), do: DemoWeb.UserView.render("edit.html", assigns)

  def handle_params(%{"id" => id}, _uri, socket) do
    user = Accounts.get_user!(id)

    {:noreply,
     assign(socket, %{
       count: 0,
       user: user,
       changeset: Accounts.change_user(user)
     })}
  end

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
