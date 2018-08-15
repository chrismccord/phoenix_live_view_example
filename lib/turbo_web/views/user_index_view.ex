defmodule TurboWeb.UserIndexView do
  use TurboWeb, :view
  use Phoenix.TurboView

  alias Turbo.Accounts

  def init(assigns) do
    Turbo.Accounts.subscribe()
    :timer.send_interval(1000, self(), :count)
    {:ok, fetch(Map.merge(assigns, %{count: 0}))}
  end

  defp fetch(assigns) do
    Map.merge(assigns, %{users: Accounts.list_users()})
  end

  def handle_info(:count, state) do
    {:ok, %{state | count: state.count + 1}}
  end

  def handle_info({Accounts, :user_updated, _}, state), do: {:ok, fetch(state)}
  def handle_info({Accounts, :user_created, _}, state), do: {:ok, fetch(state)}
  def handle_info({Accounts, :user_deleted, _}, state), do: {:ok, fetch(state)}

  def handle_event("delete_user", _, id, state) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:ok, state}
  end
end
