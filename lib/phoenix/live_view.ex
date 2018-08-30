defmodule Phoenix.LiveView do
  import Phoenix.HTML, only: [sigil_E: 2]
  @behaviour Plug

  alias Phoenix.LiveView.Socket

  def assign(%Socket{assigns: assigns} = socket, key, value) do
    %Socket{socket | assigns: Map.put(assigns, key, value)}
  end
  def assign(%Socket{assigns: assigns} = socket, attrs)
      when is_map(attrs) or is_list(attrs) do
    %Socket{socket | assigns: Enum.into(attrs, assigns)}
  end
  def update(%Socket{assigns: assigns} = socket, key, func) do
    %Socket{socket | assigns: Map.update!(assigns, key, func)}
  end

  def put_flash(%Socket{private: private} = socket, kind, msg) do
    %Socket{socket | private: Map.update(private, :flash, %{kind => msg}, &Map.put(&1, kind, msg))}
  end

  def redirect(%Socket{} = socket, opts) do
    {:stop, {:redirect, to: Keyword.fetch!(opts, :to), flash: flash(socket)}, socket}
  end
  defp flash(%Socket{private: %{flash: flash}}), do: flash
  defp flash(%Socket{}), do: nil

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      import Phoenix.HTML

      def init(assigns), do: {:ok, assigns}
      def terminate(reason, state), do: {:ok, state}
      defoverridable init: 1, terminate: 2
    end
  end

  def spawn_render(view, assigns) do
    {:ok, pid, ref} = start_view(view, assigns)
    receive do
      {^ref, rendered_view} ->
        encoded_pid = pid |> :erlang.term_to_binary() |> Base.encode64()
        signed_pid = Phoenix.Token.sign(assigns.conn, "view", encoded_pid)

        ~E(
          <script>window.viewPid = "<%= signed_pid %>"</script>
          <div id="<%= signed_pid %>">
            <%= {:safe, rendered_view} %>
          </div>
        )
    end
  end
  defp start_view(view, assigns) do
    csrf = Plug.CSRFProtection.get_csrf_token()
    ref = make_ref()

    case start_dynamic_child(ref, view, csrf, assigns) do
      {:ok, pid} -> {:ok, pid, ref}
      {:error, {%_{} = exception, [_|_] = stack}} -> reraise(exception, stack)
    end
  end
  defp start_dynamic_child(ref, view, csrf, assigns) do
    args = {{ref, self()}, view, csrf, assigns}
    DynamicSupervisor.start_child(
      DemoWeb.DynamicSupervisor,
      Supervisor.child_spec({Phoenix.LiveView.Server, args}, restart: :temporary)
    )
  end

  @doc """
  TODO
  """
  def attach(pid) do
    try do
      GenServer.call(pid, {:attach, self()})
    catch :exit, reason -> {:error, reason}
    end
  end

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, view) do
    conn
    |> Plug.Conn.put_private(:phoenix_live_view, view)
    |> Phoenix.Controller.put_view(__MODULE__)
    |> Phoenix.Controller.render("template.html")
  end

  def render("template.html", %{conn: conn} = assigns) do
    spawn_render(conn.private.phoenix_live_view, assigns)
  end

  def fetch_flash(conn, _opts \\ []) do
     case cookie_flash(conn) do
       {conn, nil} -> Phoenix.Controller.fetch_flash(conn, [])
       {conn, flash} ->
         conn
         |> Plug.Conn.put_session("phoenix_flash", flash)
         |> Phoenix.Controller.fetch_flash([])
     end
  end
  defp cookie_flash(%Plug.Conn{cookies: %{"__phoenix_flash__" => token}} = conn) do
    flash =
      case Phoenix.Token.verify(conn, "phoenix flash", token, max_age: 60_000) do
        {:ok, json_flash} -> Phoenix.json_library().decode!(json_flash)
        {:error, _reason} -> nil
      end

    {Plug.Conn.delete_resp_cookie(conn, "__phoenix_flash__"), flash}
  end
  defp cookie_flash(%Plug.Conn{} = conn), do: {conn, nil}
end
