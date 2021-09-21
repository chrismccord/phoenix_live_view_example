defmodule DemoWeb.UserLive.New do
  use DemoWeb, :live_view

  alias Demo.Accounts
  alias Demo.Accounts.User

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user(%User{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> Demo.Accounts.change_user(user_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "user created")
         |> redirect(to: Routes.user_show_path(socket, :show, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
