defmodule DemoWeb.UserLive.IndexAutoSroll do
  use Phoenix.LiveView

  Plug.Conn
  def render(assigns) do
    ~L"""
    <div class="column">
      <h2>Listing Users</h2>
      <table phx-hook="Scroll" data-page="<%= @page %>">
        <thead>
          <tr><th>Username</th><th>Email</th></tr>
        </thead>
        <tbody phx-update="append">
          <%= for user <- @users do %>
            <tr class="user-row">
              <td><%= user.username %></td>
              <td><%= user.email %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok,
     socket
     |> configure_temporary_assigns([:users])
     |> assign(page: 1, per_page: 20, count: 0)
     |> fetch()}
  end

  defp fetch(socket) do
    %{page: page, per_page: per_page} = socket.assigns
    case Demo.Accounts.list_users(page, per_page) do
      [] -> assign(socket, users: [], page: page - 1)
      [_|_] = users -> assign(socket, users: users)
    end
  end

  def handle_event("load-more", _, socket) do
    {:noreply, socket |> assign(page: socket.assigns.page + 1) |> fetch()}
  end
end


