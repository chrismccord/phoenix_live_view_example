defmodule DemoWeb.UserLive.IndexManualScroll do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <table>
      <tbody phx-update="append" id="users">
        <%= for user <- @users do %>
          <tr class="user-row" id="user-<%= user.id %>">
            <td><%= user.username %></td>
            <td><%= user.email %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    <form phx-submit="load-more">
      <button phx-disable-with="loading...">more</button>
    </form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page: 1, per_page: 10, val: 0)
     |> fetch(), temporary_assigns: [users: []]}
  end

  defp fetch(%{assigns: %{page: page, per_page: per}} = socket) do
    assign(socket, users: Demo.Accounts.list_users(page, per))
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end
