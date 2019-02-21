require Logger

defmodule DemoWeb.PacmanLive do
  use Phoenix.LiveView

  alias Demo.GameServer.Pacman, as: PMGameServer

  @width 20

  def render(assigns) do
    ~L"""
    <form phx-change="update_settings">
      <select style="display: none;" name="tick" onchange="this.blur()">
        <option value="50" <%= if @tick == 50, do: "selected" %>>50</option>
        <option value="100" <%= if @tick == 100, do: "selected" %>>100</option>
        <option value="200" <%= if @tick == 200, do: "selected" %>>200</option>
        <option value="500" <%= if @tick == 500, do: "selected" %>>500</option>
      </select>
      <input type="range" min="10" max="50" name="width" value="<%= @width %>"/>
      <%= @width %>px
    </form>
    <div class="game-container">
      <%= draw_pacman(@me, @width) %>
      <%= for player <- @others do %>
        <%= draw_pacman(player, @width) %>
      <% end %>
      <%= for {{y, x}, type} <- @blocks do %>
        <div class="block <%= type %>"
            style="left: <%= x * @width %>px;
                    top: <%= y * @width %>px;
                    width: <%= @width %>px;
                    height: <%= @width %>px;
        "></div>
      <% end %>
      <div class="block cherry"
        style="left: <%= @cherry.x * @width %>px;
                top: <%= @cherry.y * @width %>px;
                width: <%= @width %>px;
                height: <%= @width %>px;
                font-size: <%= @width %>px;
        ">&#x1F352;</div>
      <div class="stats-container" style="left: <%= @width * @board_cols + 10 %>px; top: 1px">
        You:
        <table>
          <%= player_row(@me, @width) %>
        </table>
        Leaderboard:
        <table>
          <%= for player <- @players do %>
            <%= player_row(player, @width) %>
          <% end %>
        </table>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    PMGameServer.join_game()

    socket =
      socket
      |> assign(width: @width)
      |> update_assigns()

    schedule_tick()
    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    PMGameServer.move()

    socket =
      socket
      |> update_assigns()

    schedule_tick()

    {:noreply, socket}
  end

  def handle_event("update_settings", %{"width" => width}, socket) do
    {width, ""} = Integer.parse(width)

    new_socket =
      socket
      |> assign(width: width)

    {:noreply, new_socket}
  end

  def handle_event("keydown", key, socket) do
    {:noreply, turn(socket, key)}
  end

  defp turn(socket, "ArrowLeft"), do: go(socket, :left)
  defp turn(socket, "ArrowDown"), do: go(socket, :down)
  defp turn(socket, "ArrowUp"), do: go(socket, :up)
  defp turn(socket, "ArrowRight"), do: go(socket, :right)
  defp turn(socket, _), do: socket

  defp go(%{assigns: %{me: %{heading: heading}}} = socket, heading), do: socket

  defp go(socket, heading) do
    PMGameServer.set_heading(heading)
    update_assigns(socket)
  end

  defp schedule_tick, do: Process.send_after(self(), :tick, PMGameServer.tick())

  defp update_assigns(socket) do
    %{players: players, cherry: cherry, tick: tick, blocks: blocks, board_cols: board_cols} =
      PMGameServer.get_state()

    {[me], others} = Enum.split_with(players, fn %{pid: pid} -> pid == self() end)

    socket
    |> assign(me: me)
    |> assign(others: others)
    |> assign(cherry: cherry)
    |> assign(tick: tick)
    |> assign(blocks: blocks)
    |> assign(players: players)
    |> assign(others: others)
    |> assign(board_cols: board_cols)
  end

  def draw_pacman(pacman, width, at_origin \\ false) do
    {x, y, absolute} =
      if at_origin do
        {0, 0, ""}
      else
        {pacman.x, pacman.y, "position: absolute;"}
      end

    assigns = %{pacman: pacman, width: width, x: x, y: y, absolute: absolute}

    ~L"""
    <div class="pacman"
          phx-keydown="keydown"
          phx-target="window"
            style="transform: rotate(<%= @pacman.rotation %>deg);
                  <%= absolute %>
                  left: <%= @x * @width %>px;
                  top: <%= @y * @width %>px;
                  width: <%= @width %>px;
                  height: <%= @width %>px;
        ">
      <div class="pacman-top" style="width: <%= @width %>px; height: <%= @width / 2 %>px; background-color: #<%= @pacman.color %>;"></div>
      <div class="pacman-bottom" style="width: <%= @width %>px; height: <%= @width / 2 %>px; background-color: #<%= @pacman.color %>;"></div>
    </div>
    """
  end

  def player_row(player, width) do
    assigns = %{player: player, width: width}

    ~L"""
    <tr><td><%= player.score %></td><td><%= draw_pacman(player, @width, true) %></td><td><%= player.name %></td></tr>
    """
  end
end
