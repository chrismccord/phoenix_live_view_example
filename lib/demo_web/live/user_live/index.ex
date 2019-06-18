defmodule DemoWeb.UserLive.Index do
  use Phoenix.LiveView

  alias Demo.Accounts
  alias DemoWeb.UserView
  alias DemoWeb.Router.Helpers, as: Routes

  def render(assigns), do: UserView.render("index.html", assigns)

  def mount(_session, socket) do
    if connected?(socket), do: Demo.Accounts.subscribe()

    {:ok,
     socket
     |> assign(:page, 1)
     |> assign(:per_page, 5)}
  end

  def handle_params(params, _url, socket) do
    {page_num, ""} = Integer.parse(params["page"] || "1")
    {:noreply, socket |> assign(page: page_num) |> fetch()}
  end

  defp fetch(socket) do
    %{page: page, per_page: per_page} = socket.assigns
    assign(socket, users: Accounts.list_users(page, per_page))
  end


  def handle_info({Accounts, [:user | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("keydown", "ArrowRight", socket) do
    {:noreply, go_page(socket, socket.assigns.page + 1)}
  end
  def handle_event("keydown", "ArrowLeft", socket) do
    {:noreply, go_page(socket, socket.assigns.page - 1)}
  end
  def handle_event("keydown", _, socket), do: {:noreply, socket}

  def handle_event("delete_user", id, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:noreply, socket}
  end

  defp go_page(socket, page) when page > 0 do
    live_redirect(socket, to: Routes.live_path(socket, __MODULE__, page: page))
  end
  defp go_page(socket, _page), do: socket
end
