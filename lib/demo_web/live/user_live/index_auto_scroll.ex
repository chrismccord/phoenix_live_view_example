defmodule DemoWeb.UserLive.Row do
  use Phoenix.LiveComponent

  defmodule Email do
    use Phoenix.LiveComponent

    def mount(socket) do
      {:ok, assign(socket, count: 0)}
    end

    def render(assigns) do
      ~L"""
      <span id="<%= @id %>" phx-click="click" phx-target="#<%= @id %>">
        Email: <%= @email %> <%= @count %>
      </span>
      """
    end

    def handle_event("click", _, socket) do
      {:noreply, update(socket, :count, &(&1 + 1))}
    end
  end

  def mount(socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~L"""
    <tr class="user-row" id="<%= @id %>" phx-click="click" phx-target="#<%= @id %>">
      <td phx-hook="LazyArtwork">
        <img
          class="user-artwork"
          src=<%= DemoWeb.Router.Helpers.static_url(DemoWeb.Endpoint, "/images/1x1.gif") %> ;
          data-src=<%= Map.get(@user.artwork, "url") %>
          alt=<%= @user.username %>
          height=<%= Map.get(@user.artwork, "height") %>
          width=<%= Map.get(@user.artwork, "width") %>
          style="background-color: lightgray"
          role="presentation"
          phx-update="ignore"
          data-lazy-artwork
        />
      </td>
      <td><%= @user.username %> <%= @count %></td>
      <td>
        <%= live_component @socket, Email, id: "email-#{@id}", email: @user.email %>
      </td>
    </tr>
    """
  end

  def handle_event("click", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end
end

defmodule DemoWeb.UserLive.IndexAutoScroll do
  use Phoenix.LiveView

  alias DemoWeb.UserLive.Row

  def render(assigns) do
    ~L"""
    <table>
      <tbody id="users" phx-update="append">
        <%= for user <- @users do %>
          <%= live_component @socket, Row, id: "user-#{user.id}", user: user %>
        <% end %>
      </tbody>
    </table>

    <div phx-hook="ObserverInfiniteScroll" data-page="<%= @page %>"></div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page: 1, per_page: 20)
     |> fetch(), temporary_assigns: [users: []]}
  end

  defp fetch(%{assigns: %{page: page, per_page: per}} = socket) do
    assign(socket, users: Demo.Accounts.list_users(page, per))
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end
