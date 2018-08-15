defmodule TurboWeb.UserEditView do
  use TurboWeb, :view
  use Phoenix.TurboView

  alias Turbo.Accounts

  def init(%{conn: conn} = assigns) do
    user = Accounts.get_user!(conn.params["id"])

    {:ok, Map.merge(assigns, %{
      count: 0,
      user: user,
      changeset: Accounts.change_user(user),
    })}
  end

  def handle_event("validate", _id, %{"user" => params}, state) do
    changeset =
      state.user
      |> Turbo.Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:ok, %{state | changeset: changeset}}
  end

  def handle_event("save", _id, %{"user" => user_params}, state) do
    case Accounts.update_user(state.user, user_params) do
      {:ok, user} ->
        state
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(state.conn, TurboWeb.UserShowView, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        {:ok, %{state | changeset: changeset}}
    end
  end
end
