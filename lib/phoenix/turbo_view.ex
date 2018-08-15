defmodule Phoenix.TurboView do
  import Phoenix.HTML, only: [sigil_E: 2]
  @behaviour Plug

  @flash :__phx_flash__

  def put_flash(state, kind, msg) do
    Map.update(state, @flash, %{kind => msg}, fn flash -> Map.put(flash, kind, msg) end)
  end

  def redirect(state, opts) do
    {:stop, {:redirect, to: Keyword.fetch!(opts, :to), flash: flash(state)}, state}
  end
  defp flash(%{@flash => flash}), do: flash
  defp flash(_state), do: nil

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)
      @phoenix_template unquote(opts)[:template] || "template.html"
      @before_compile unquote(__MODULE__)

      def init(assigns), do: {:ok, assigns}
      def terminate(reason, state), do: {:ok, state}
      defoverridable init: 1, terminate: 2
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __render_template__(template, assigns) do
        render_template(template, assigns)
      end

      defoverridable render: 2
      def render(template = @phoenix_template, assigns) do
        unquote(__MODULE__).spawn_render(__MODULE__, template, assigns)
      end
      def render(template, assigns) do
        super(template, assigns)
      end
    end
  end

  def spawn_render(view, template, assigns) do
    {:ok, pid, ref} = start_view(view, template, assigns)
    receive do
      {^ref, rendered_view} ->
        encoded_pid = pid |> :erlang.term_to_binary() |> Base.encode64()
        signed_pid = Phoenix.Token.sign(assigns.conn, "view", encoded_pid)

        ~E(
          <script>window.viewPid = "<%= signed_pid %>"</script>
          <div id="<%= signed_pid %>">
            <%= rendered_view %>
          </div>
        )
    end
  end
  defp start_view(view, template, assigns) do
    csrf = Plug.CSRFProtection.get_csrf_token()
    ref = make_ref()

    case start_dynamic_child(ref, view, template, csrf, assigns) do
      {:ok, pid} -> {:ok, pid, ref}
      {:error, {%_{} = exception, [_|_] = stack}} -> reraise(exception, stack)
    end
  end
  defp start_dynamic_child(ref, view, template, csrf, assigns) do
    args = {{ref, self()}, view, template, csrf, assigns}
    DynamicSupervisor.start_child(
      TurboWeb.DynamicSupervisor,
      Supervisor.child_spec({Phoenix.TurboView.Server, args}, restart: :temporary)
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
    |> Phoenix.Controller.put_view(view)
    |> Phoenix.Controller.render("template.html")
  end
end
