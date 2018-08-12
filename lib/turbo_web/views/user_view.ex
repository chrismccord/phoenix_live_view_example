defmodule TurboWeb.UserView do
  use TurboWeb, :view
  use Phoenix.TurboView, components: ~w(new.html edit.html)

  def init(assigns) do
    :timer.send_interval(500, self(), :progress)
    {:ok, Map.put(assigns, :count, 0)}
  end

  def handle_info(:progress, state) do
    {:ok, %{state | count: state.count + 1}}
  end

  def handle_event("validate", _id, %{"user" => params}, state) do
    changeset =
      state.changeset.data
      |> Turbo.Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:ok, %{state | changeset: changeset}}
  end
end
