defmodule TurboWeb.UserIndexView do
  use TurboWeb, :view
  use Phoenix.TurboView, components: ~w(index.html)

  alias Turbo.Accounts
  alias Turbo.Accounts.User

  def init(%{users: users} = assigns) do
    Turbo.Accounts.subscribe()

    {:ok, %{assigns | users: for(u <- users, into: %{}, do: {u.id, u})}}
  end

  def handle_info({Accounts, :user_updated, %User{id: id} = user}, state) do
    case Map.fetch(state.users, id) do
      {:ok, _user} ->  {:ok, put_in(state, [:users, id], user)}
      :error -> {:ok, state}
    end
  end

  def handle_info({Accounts, :user_created, user}, state) do
    {:ok, %{state | users: Map.put(state.users, user.id, user)}}
  end

  def handle_info({Accounts, :user_deleted, user}, state) do
    {:ok, %{state | users: Map.delete(state.users, user.id)}}
  end

  def handle_event("delete_user", _, id, state) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:ok, state}
  end
end
