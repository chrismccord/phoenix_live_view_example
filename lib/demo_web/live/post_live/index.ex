defmodule DemoWeb.PostLive.Index do
  use DemoWeb, :live_view

  alias Demo.Blog
  alias Demo.Blog.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(50, self(), :tick)
    {:ok, assign(socket, posts: list_posts(), count: 0)}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Blog.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Blog.get_post!(id)
    {:ok, _} = Blog.delete_post(post)

    {:noreply, assign(socket, :posts, list_posts())}
  end

  defp list_posts do
    Blog.list_posts()
  end
end
