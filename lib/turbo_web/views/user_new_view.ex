defmodule TurboWeb.UserNewView do
  use TurboWeb, :view
  use Phoenix.TurboView

  alias Turbo.Accounts
  alias Turbo.Accounts.User

  def init(assigns) do
    {:ok, Map.merge(assigns, %{
      count: 0,
      changeset: Accounts.change_user(%User{}),
    })}
  end

  def handle_event("validate", _id, %{"user" => params}, state) do
    changeset =
      %User{}
      |> Turbo.Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:ok, %{state | changeset: changeset}}
  end

  def handle_event("save", _id, %{"user" => user_params}, state) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        state
        |> put_flash(:info, "user created")
        |> redirect(to: Routes.user_path(state.conn, TurboWeb.UserShowView, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        {:ok, %{state | changeset: changeset}}
    end
  end
end
