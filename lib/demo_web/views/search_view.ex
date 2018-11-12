defmodule DemoWeb.SearchView do
  use Phoenix.LiveView

  def render(assigns) do
    ~E"""
    <form phx-change="search">
      <input type="text" name="query" list="suggestions" placeholder="Search..."/>
      <datalist id="suggestions">
          <%= for match <- @suggestions do %>
            <option value="<%= match %>"><%= match %></option>
          <% end %>
        </select>
      </datalist>
    </form>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, query: "", suggestions: [])}
  end

  def handle_event("search", _, %{"query" => query}, socket) do
    {:noreply, suggest(socket, query)}
  end

  defp suggest(socket, ""), do: assign(socket, suggestions: [])
  defp suggest(socket, query) do
    {matches, _} = System.cmd("grep", ["^#{query}.*", "-m", "5", "/usr/share/dict/words"])
    assign(socket, :suggestions, String.split(matches, "\n"))
  end
end
