defmodule Demo.Life do
  @off "🀆"
  @on "🀫"
  
  defstruct width: 3, 
         height: 3, 
         cells: %{}

  def new(args \\ []), do: __struct__(args)
  
  def new_random(width, height) do
    cells = 
      (for x <- (1..width), y <- (1..height) do
        {{x, y}, hd Enum.shuffle([@on, @off]) }
      end
      |> Map.new)

    [cells: cells, height: height, width: width]
    |> new
  end
  
  defp fetch(%__MODULE__{}=board, x, y) do
    Map.get(board.cells, {x, y}, @off)
  end 
  
  defp neighbors(board, x, y) do
    [
      fetch(board, x-1, y-1), fetch(board, x, y-1), fetch(board, x+1, y-1), 
      fetch(board, x-1, y),                         fetch(board, x+1, y), 
      fetch(board, x-1, y+1), fetch(board, x, y+1), fetch(board, x+1, y+1)
    ]
  end
  
  defp neighbor_count(board, x, y) do
    board
    |> neighbors(x, y)
    |> Enum.filter(fn cell -> cell == @on end)
    |> Enum.count
  end
  
  def next_board(board) do
    new_cells = 
      for x <- (1..board.width), 
          y <- (1..board.height) do

          cell = fetch(board, x, y)
          count = neighbor_count(board, x, y)
          
          {{x, y}, rule(cell, count)}

      end
      |> Map.new
    
    %{board| cells: new_cells}
  end
  
  defp rule(_cell, neighbor_count) when neighbor_count < 2 do
    @off
  end
  defp rule(_cell, neighbor_count) when neighbor_count > 3 do
    @off
  end
  defp rule(_cell, 3), do: @on
  defp rule(cell, _neighbor_count), do: cell
  
  def render(board) do
    for y <- (1..board.height) do
      render_row(board, y)
    end
    |> Enum.join("\n")
  end
  defp render_row(board, y) do
    for x <- (1..board.width) do
      fetch(board, x, y)
    end
    |> Enum.join("")
  end
end