defmodule DemoWeb.LifeLive do
  use Phoenix.LiveView
  alias Demo.Life

  def render(assigns) do
    ~L"""
    <div>
      <h1>Life</h1>
      <pre><%= Life.render @board %></pre>
      <a href="https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life">
        Conway's Game of Life
      </a>
    </div>
    """
  end

  def mount(_session, socket) do
    :timer.send_interval(100, self(), :tick)
    
    {:ok, assign( socket, board: Life.new_random(80, 40))}
  end
  
  
  def handle_info(:tick, socket) do
    {
      :noreply, 
      assign(socket, board: Life.next_board(socket.assigns.board))
    }
  end
end