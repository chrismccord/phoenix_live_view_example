defmodule DemoWeb.UserLive.IndexAutoScroll do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <table phx-update="append"
           phx-hook="InfiniteScroll"
           data-page="<%= @page %>">
      <%= for user <- @users do %>
        <tr>
          <td><%= user.username %></td>
          <td><%= user.email %></td>
        </tr>
      <% end %>
    </table>
    """
  end

  def mount(_session, socket) do
    {:ok,
     socket
     |> configure_temporary_assigns([:users])
     |> assign(page: 1, per_page: 10)
     |> fetch()}
  end

  defp fetch(%{assigns: %{page: page, per_page: per}} = socket) do
    assign(socket, users: Demo.Accounts.list_users(page, per))
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end

