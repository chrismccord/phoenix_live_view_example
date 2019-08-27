defmodule DemoWeb.UserLive.New do
  use Phoenix.LiveView

  alias DemoWeb.UserLive
  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts
  alias Demo.Accounts.User

  def mount(_session, socket) do
    changeset =
      case get_connect_params(socket) do
        %{"stashed_form" => encoded} ->
          %User{}
          |> Accounts.change_user(Plug.Conn.Query.decode(encoded)["user"])
          |> Map.put(:action, :insert)

        _ ->
          Accounts.change_user(%User{})
      end

    {:ok, assign(socket, changeset: changeset)}
  end

  def render(assigns), do: Phoenix.View.render(DemoWeb.UserView, "new.html", assigns)

  def handle_event("validate", %{"user" => user_params} = params, socket) do
    changeset =
      %User{}
      |> Demo.Accounts.change_user(user_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params} = params, socket) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:stop,
         socket
         |> put_flash(:info, "user created")
         |> redirect(to: Routes.live_path(socket, UserLive.Show, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
