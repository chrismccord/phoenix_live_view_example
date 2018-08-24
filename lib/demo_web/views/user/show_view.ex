defmodule DemoWeb.User.ShowView do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts
  alias Phoenix.LiveView.Socket

  def render(assigns) do
    ~E|
    <div class="animated-sin-wave" phx-click="switch">
      <%= render_rainbow(assigns) %>
    </div>
    <h2>Show User</h2>
    <ul>
      <li><b>Username:</b> <%= @user.username %></li>
      <li><b>Email:</b> <%= @user.email %></li>
      <li><b>Phone:</b> <%= @user.phone_number %></li>
    </ul>
    <span><%= link "Edit", to: Routes.user_path(@conn, DemoWeb.User.EditView, @user) %></span>
    <span><%= link "Back", to: Routes.user_path(@conn, DemoWeb.User.IndexView) %></span>
    |
  end
  defp render_rainbow(%{count: count, bar_count: bar_count}) do
    bar_width = 100 / bar_count

    for i <- 0..bar_count do
      translate_y = :math.sin(count / 10 + i / 5) * 100 * 0.5
      hue = rem(trunc(360 / bar_count * i - count), 360)
      color = "hsl(#{hue},95%,55%)"
      rotation = rem(trunc(count + i), 360)
      bar_x = bar_width * i
      style = "width: #{bar_width}%; left: #{bar_x}%; transform: scale(0.8,.5) translateY(#{translate_y}%) rotate(#{rotation}deg); background-color: #{color};"
      ~E|<div class="bar" style="<%= style %>"></div>|
    end
  end

  def init(%Socket{assigns: %{conn: %{params: %{"id" => id}}}} = socket) do
    inner_window_width = 1000
    {:ok, _} = :timer.send_interval(17, self(), :next_frame) # 60 FPS

    Demo.Accounts.subscribe(id)
    {:ok, fetch(assign(socket, %{
      id: id,
      step: 0.5,
      count: 0,
      inner_window_width: inner_window_width,
      bar_count: Enum.min([200, trunc(:math.floor(inner_window_width / 15))]),
    }))}
  end

  defp fetch(%Socket{assigns: %{id: id}} = socket) do
    assign(socket, %{
      user: Accounts.get_user!(id),
    })
  end

  def handle_info(:next_frame, socket) do
    %{count: count, step: step} = socket.assigns
    {:ok, assign(socket, count: count + step)}
  end

  def handle_info({Accounts, :user_updated, _}, socket), do: {:ok, fetch(socket)}

  def handle_info({Accounts, :user_deleted, _}, socket) do
    socket
    |> put_flash(:error, "This user has been deleted from the system")
    |> redirect(to: Routes.user_path(socket.assigns.conn, DemoWeb.User.IndexView))
  end

  def handle_event("switch", _id, _val, %{assigns: assigns} = socket) do
    {:ok, assign(socket, step: assigns.step * -1)}
  end
end
