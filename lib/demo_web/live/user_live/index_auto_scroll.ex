defmodule DemoWeb.UserLive.IndexAutoScroll do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <table>
      <tbody id="users"
             phx-update="append"
             phx-hook="InfiniteScroll"
             data-page="<%= @page %>">
        <%= for user <- @users do %>
          <tr class="user-row" id="user-<%= user.id %>">
            <td><%= user.username %></td>
            <td><%= user.email %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def mount(_session, socket) do
    {:ok,
     socket
     |> assign(page: 1, per_page: 10)
     |> fetch(), temporary_assigns: [:users]}
  end

  defp fetch(%{assigns: %{page: page, per_page: per}} = socket) do
    assign(socket, users: Demo.Accounts.list_users(page, per))
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end
