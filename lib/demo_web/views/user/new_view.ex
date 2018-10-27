defmodule DemoWeb.User.NewView do
  use Phoenix.LiveView

  alias DemoWeb.UserView
  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts
  alias Demo.Accounts.User

  def authorize(_params, _session, socket) do
    {:ok, assign(socket, %{
      count: 0,
      changeset: Accounts.change_user(%User{}),
    })}
  end

  def render(assigns), do: UserView.render("new.html", assigns)

  def handle_event("validate", _id, %{"user" => params}, socket) do
    changeset =
      %User{}
      |> Demo.Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", _id, %{"user" => user_params}, socket) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        socket
        |> put_flash(:info, "user created")
        |> redirect(to: Routes.user_path(DemoWeb.Endpoint, DemoWeb.User.ShowView, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
