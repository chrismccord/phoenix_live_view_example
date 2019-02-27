defmodule Demo.GameServer.Pacman do
  use GenServer

  alias Demo.GameServer.Pacman.Player

  @board [
    ~w(X X X X X X X X X X X X X X X X X X X X X X X X X X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 X X X X X X 0 0 0 0 0 0 X X X X X X 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 X X X X X X X X 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 X X X X X X 0 0 0 0 0 0 X X X X X X 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X X X X X X X X X X X X X X X X X X X X X X X X X X)
  ]
  @board_rows length(@board)
  @board_cols length(hd(@board))
  @tick 200
  @rotation %{left: 180, right: 0, up: -90, down: 90}

  ## Client

  def start_link(_) do
    blocks = build_board()

    GenServer.start_link(
      __MODULE__,
      %{
        players: [],
        cherry: new_cherry_loc(blocks),
        blocks: blocks,
        tick: @tick,
        board_rows: @board_rows,
        board_cols: @board_cols
      },
      name: __MODULE__
    )
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def join_game() do
    GenServer.call(__MODULE__, :join_game)
  end

  def move() do
    GenServer.call(__MODULE__, :move)
  end

  def set_heading(heading) do
    GenServer.call(__MODULE__, {:set_heading, heading})
  end

  ## Server

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call(:join_game, {from, _}, %{players: players} = state) do
    {:reply, :ok, %{state | players: [Player.new(from) | players] |> sort_by_score()}}
  end

  @impl GenServer
  def handle_call(:move, {from, _}, %{players: players, blocks: blocks, cherry: cherry} = state) do
    {%Player{heading: heading, x: x, y: y, score: score} = player, others} =
      get_player(players, from)

    maybe_row = row(y, heading)
    maybe_col = col(x, heading)

    {y, x} =
      case block(maybe_row, maybe_col, blocks) do
        :wall -> {y, x}
        :empty -> {maybe_row, maybe_col}
      end

    {cherry, score} =
      case cherry do
        %{x: ^x, y: ^y} -> {new_cherry_loc(blocks), score + 50}
        _ -> {cherry, score}
      end

    player = %Player{player | x: x, y: y, score: score}
    state = %{state | cherry: cherry, players: [player | others] |> sort_by_score()}
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:set_heading, heading}, {from, _}, %{players: players} = state) do
    {player, others} = get_player(players, from)
    player = %Player{player | heading: heading, rotation: Map.fetch!(@rotation, heading)}
    state = %{state | players: [player | others] |> sort_by_score()}
    {:reply, :ok, state}
  end

  defp col(val, :left) when val - 1 >= 1, do: val - 1
  defp col(val, :right) when val + 1 < @board_cols - 1, do: val + 1
  defp col(val, _), do: val

  defp row(val, :up) when val - 1 >= 1, do: val - 1
  defp row(val, :down) when val + 1 < @board_rows - 1, do: val + 1
  defp row(val, _), do: val

  defp get_player(players, player_pid) do
    {[player], others} = Enum.split_with(players, fn %Player{pid: pid} -> pid == player_pid end)
    others = Enum.filter(others, fn %Player{pid: pid} -> Process.alive?(pid) end)
    {player, others}
  end

  defp new_cherry_loc(blocks) do
    x = :rand.uniform(@board_cols) - 1
    y = :rand.uniform(@board_rows) - 1

    case block(y, x, blocks) do
      :wall -> new_cherry_loc(blocks)
      :empty -> %{x: x, y: y}
    end
  end

  defp sort_by_score(players),
    do:
      Enum.sort(players, fn
        %Player{score: score, name: name1}, %Player{score: score, name: name2} -> name1 >= name2
        %Player{score: score1}, %Player{score: score2} -> score1 >= score2
      end)

  def block(row, col, blocks) do
    Map.fetch!(blocks, {row, col})
  end

  defp build_board() do
    {_, blocks} =
      Enum.reduce(@board, {0, %{}}, fn row, {y_index, acc} ->
        {_, blocks} =
          Enum.reduce(row, {0, acc}, fn
            "X", {x_index, acc} ->
              {x_index + 1, Map.put(acc, {y_index, x_index}, :wall)}

            "0", {x_index, acc} ->
              {x_index + 1, Map.put(acc, {y_index, x_index}, :empty)}
          end)

        {y_index + 1, blocks}
      end)

    blocks
  end
end
