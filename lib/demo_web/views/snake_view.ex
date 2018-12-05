defmodule DemoWeb.SnakeView do
  use Phoenix.LiveView

  @tick 100
  @width 16
  @snake_length 5

  @board [
    ~w(X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X),
  ]
  @board_rows length(@board)
  @board_cols length(hd(@board))

  def render(%{game_state: :over} = assigns) do
    ~L"""
    <div class="snake-container">
      <div class="game-over">
        <h1>GAME OVER <small>SCORE: <%= @score %></h1>
        <button phx-click="new_game">NEW GAME</button>
      </div>
    </div>
    """
  end
  def render(%{game_state: :playing} = assigns) do
    ~L"""
    <div class="snake-controls">
      <form phx-change="update_size" phx-submit="tick" phx-submit-every="<%= @tick %>">
        <select name="tick" onchange="this.blur()">
          <option value="50" <%= if @tick == 50, do: "selected" %>>50</option>
          <option value="100" <%= if @tick == 100, do: "selected" %>>100</option>
          <option value="200" <%= if @tick == 200, do: "selected" %>>200</option>
          <option value="500" <%= if @tick == 500, do: "selected" %>>500</option>
        </select>
        <input type="range" min="5" max="50" name="width" value="<%= @width %>" />
        <button phx-click="smaller">-</button>
        <button phx-click="bigger">+</button>
        <%= @width %>px
      </form>
    </div>
    <div class="snake-container" phx-keydown="keydown" phx-target="window">
      <div class="dpad">
        <div class="control up"><a href="#" phx-click="keydown" phx-value="ArrowUp">➤</a></div>
        <div class="control down"><a href="#" phx-click="keydown" phx-value="ArrowDown">➤</a></div>
        <div class="control left"><a href="#" phx-click="keydown" phx-value="ArrowLeft">➤</a></div>
        <div class="control right"><a href="#"phx-click="keydown" phx-value="ArrowRight">➤</a></div>
      </div>
      <h3 class="score" style="font-size: <%= @width %>px;">SCORE:&nbsp;<%= @score %></h3>
      <%= for {row, col} <- [{@row, @col} | @tail] do %>
        <div class="block tail"
            style="left: <%= x(col, @width) %>px;
                    top: <%= y(row, @width) %>px;
                    width: <%= @width %>px;
                    height: <%= @width %>px;
        "></div>
      <% end %>
      <%= for {row, col} <- @cherries do %>
        <div class="block cherry"
            style="left: <%= x(col, @width) %>px;
                    top: <%= y(row, @width) %>px;
                    width: <%= @width %>px;
                    height: <%= @width %>px;
        "></div>
      <% end %>
      <%= for {_, block} <- @blocks, block.type !== :empty do %>
        <div class="block <%= block.type %>"
            style="left: <%= block.x %>px;
                    top: <%= block.y %>px;
                    width: <%= block.width %>px;
                    height: <%= block.width %>px;
        "></div>
      <% end %>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, new_game(socket)}
  end

  defp new_game(socket) do
    defaults = %{
      score: 0,
      game_state: :playing,
      heading: :stationary,
      pending_heading: :stationary,
      width: @width,
      tick: @tick,
      row: 1,
      col: 6,
      max_length: @snake_length,
      tail: [{1, 6}],
      cherries: [],
    }

    new_socket =
      socket
      |> assign(defaults)
      |> build_board()
      |> game_loop()

    if connected?(new_socket) do
      place_cherries(new_socket, 2)
    else
      new_socket
    end
  end

  def handle_event("smaller", _, socket) do
    {:noreply, update_size(socket, socket.assigns.width - 5)}
  end
  def handle_event("bigger", _, socket) do
    {:noreply, update_size(socket, socket.assigns.width + 5)}
  end

  def handle_event("update_size", %{"width" => width}, socket) do
    {width, ""} = Integer.parse(width)
    {:noreply, update_size(socket, width)}
  end

  def handle_event("new_game", _, socket) do
    {:noreply, new_game(socket)}
  end

  def handle_event("keydown", key, socket) do
    {:noreply, turn(socket, socket.assigns.heading, key)}
  end

  def handle_event("tick", %{"tick" => tick}, socket) do
    {tick, ""} = Integer.parse(tick)
    new_socket =
      socket
      |> assign(:tick, tick)
      |> game_loop()

    {:noreply, new_socket}
  end

  defp update_size(socket, width) do
    socket
    |> assign(width: width)
    |> build_board()
  end

  defp turn(socket, :right, "ArrowLeft"), do: socket
  defp turn(socket, _, "ArrowLeft"), do: go(socket, :left)
  defp turn(socket, :up, "ArrowDown"), do: socket
  defp turn(socket, _, "ArrowDown"), do: go(socket, :down)
  defp turn(socket, :down, "ArrowUp"), do: socket
  defp turn(socket, _, "ArrowUp"), do: go(socket, :up)
  defp turn(socket, :left, "ArrowRight"), do: socket
  defp turn(socket, _, "ArrowRight"), do: go(socket, :right)
  defp turn(socket, _, _), do: socket

  defp go(socket, heading), do: assign(socket, pending_heading: heading)

  defp build_board(socket) do
    width = socket.assigns.width

    {_, blocks} =
      Enum.reduce(@board, {0, %{}}, fn row, {y_idx, acc} ->
        {_, blocks} =
          Enum.reduce(row, {0, acc}, fn
            "X", {x_idx, acc} ->
              {x_idx + 1, Map.put(acc, {y_idx, x_idx}, wall(x_idx, y_idx, width))}

            "0", {x_idx, acc} ->
              {x_idx + 1, Map.put(acc, {y_idx, x_idx}, empty(x_idx, y_idx, width))}
          end)

        {y_idx + 1, blocks}
      end)

    assign(socket, :blocks, blocks)
  end
  defp wall(x_idx, y_idx, width) do
    %{type: :wall, x: x_idx * width, y: y_idx * width, width: width}
  end
  defp empty(x_idx, y_idx, width) do
    %{type: :empty, x: x_idx * width, y: y_idx * width, width: width}
  end

  defp place_cherries(socket, count) do
    Enum.reduce(0..(count - 1), socket, fn _, acc -> place_random_cherry(acc) end)
  end
  def place_random_cherry(socket) do
    place_cherry(socket, Enum.random(0..(@board_rows - 1)), Enum.random(0..(@board_cols - 1)))
  end
  defp place_cherry(socket, row, col) do
    case block(socket, row, col) do
      :empty -> assign(socket, :cherries, [{row, col} | socket.assigns.cherries])
      _ -> place_random_cherry(socket)
    end
  end

  defp game_loop(%{assigns: %{pending_heading: :stationary}} = socket), do: socket
  defp game_loop(socket) do
    %{pending_heading: heading} = socket.assigns
    {row_before, col_before} = coord(socket)
    maybe_row = row(row_before, heading)
    maybe_col = col(col_before, heading)

    {row, col, collision} =
      case block(socket, maybe_row, maybe_col) do
        :wall -> {maybe_row, maybe_col, :wall}
        :tail -> {maybe_row, maybe_col, :tail}
        :empty -> {maybe_row, maybe_col, :empty}
        :cherry -> {maybe_row, maybe_col, :cherry}
      end

    socket
    |> advance_tail({row_before, row}, {col_before, col})
    |> assign(:row, row)
    |> assign(:col, col)
    |> assign(:heading, heading)
    |> handle_collision(collision)
  end

  defp advance_tail(socket, {row, row}, {col, col}), do: socket
  defp advance_tail(socket, {row, _}, {col, _}) do
    tail = [{row, col} | socket.assigns.tail]
    if length(tail) < socket.assigns.max_length do
      assign(socket, :tail,  tail)
    else
      assign(socket, :tail,  Enum.drop(tail, -1))
    end
  end

  def handle_collision(socket, :wall), do: game_over(socket)
  def handle_collision(socket, :tail), do: game_over(socket)
  def handle_collision(socket, :cherry), do: level_up(socket)
  def handle_collision(socket, :empty), do: socket

  defp game_over(socket), do: assign(socket, :game_state, :over)

  defp level_up(socket) do
    new_cherries = Enum.filter(socket.assigns.cherries, (&(&1 !== coord(socket))))

    socket
    |> assign(:score, socket.assigns.score + 10)
    |> assign(:max_length, socket.assigns.max_length + 4)
    |> assign(:cherries, new_cherries)
    |> place_cherries(1)
  end

  defp col(val, :left) when val - 1 >= 0, do: val - 1
  defp col(val, :right) when val + 1 < @board_cols, do: val + 1
  defp col(val, _), do: val

  defp row(val, :up) when val - 1 >= 0, do: val - 1
  defp row(val, :down) when val + 1 < @board_rows, do: val + 1
  defp row(val, _), do: val

  def block(socket, row, col) do
    cond do
      {row, col} in socket.assigns.cherries -> :cherry
      {row, col} in socket.assigns.tail -> :tail
      true -> Map.fetch!(socket.assigns.blocks, {row, col}).type
    end
  end

  defp x(x, width), do: x * width
  defp y(y, width), do: y * width

  defp coord(socket), do: {socket.assigns.row, socket.assigns.col}
end
