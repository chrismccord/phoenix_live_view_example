defmodule DemoWeb.UserLive.IndexManualScroll do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <button phx-click="inc">click</button> <%= @val %>
    <table phx-update="append">
      <%= for user <- @users do %>
        <tr id="user-<%= user.id %>" phx-hook="Click" class="<%= if Map.get(user, :static), do: "", else: "user-row" %>">
          <td><%= user.username %></td>
          <td><%= user.email %></td>
          <td>
            <%= if @focus_id == user.id do %>
              editing...
            <% else %>
              <button phx-click="focus" phx-value-id="<%= user.id %>">edit</button>
            <% end %>
          </td>
        </tr>
      <% end %>
    </table>
    <form phx-submit="load-more">
      <button phx-disable-with="loading...">more</button>
    </form>
    """
  end

  def mount(_session, socket) do
    {:ok,
     socket
     |> configure_temporary_assigns([:users])
     |> assign(page: 1, per_page: 2, focus_id: nil, val: 0)
     |> fetch()}
  end

  defp fetch(%{assigns: %{page: page, per_page: per}} = socket) do
    assign(socket, users: Demo.Accounts.list_users(page, per))
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end

  def handle_event("focus", %{"id" => id}, socket) do
    prev_focus_id = socket.assigns.focus_id
    prev = if prev_focus_id, do: [Map.put(Demo.Accounts.get_user!(prev_focus_id), :static, true)], else: []
    user = Map.put(Demo.Accounts.get_user!(id), :static, true)
    {:noreply, assign(socket, focus_id: user.id, users: [user | prev])}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end
end
