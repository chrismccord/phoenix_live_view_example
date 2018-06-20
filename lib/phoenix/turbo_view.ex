defmodule Phoenix.TurboView do
  use GenServer

  @timeout 20_000

  defmacro __using__(opts) do
    quote do
      @phoenix_components unquote(opts)[:components] || []
      @before_compile unquote(__MODULE__)

      def init(assigns), do: {:ok, assigns}
      defoverridable init: 1
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __render_template__(template, assigns) do
        render_template(template, assigns)
      end

      defoverridable render: 2
      def render(template, assigns) when template in @phoenix_components do
        unquote(__MODULE__).spawn_render(__MODULE__, template, assigns)
      end
      def render(template, assigns) do
        super(template, assigns)
      end
    end
  end

  def start_link(assigns), do: GenServer.start_link(__MODULE__, assigns)

  def attach(pid) do
    try do
      GenServer.call(pid, {:attach, self()})
    catch :exit, reason -> {:error, reason}
    end
  end

  def init({{ref, request_pid}, csrf, assigns}) do
    Process.put(:plug_masked_csrf_token, csrf)

    assigns
    |> assigns.view_module.init()
    |> configure_init(assigns, {ref, request_pid})
  end
  defp configure_init({:ok, new_assigns}, assigns, {ref, request_pid}) do
    configure_init({:ok, new_assigns, []}, assigns, {ref, request_pid})
  end
  defp configure_init({:ok, new_assigns, opts}, assigns, {ref, request_pid}) do
    send(request_pid, {ref, new_assigns})
    state = %{
      view_module: assigns.view_module,
      view_template: assigns.view_template,
      assigns: new_assigns,
      channel_pid: nil,
      shutdown_timer: nil,
      timeout: opts[:timeout] || @timeout,
    }
    {:ok, state}
  end

  def spawn_render(view, template, assigns) do
    {:ok, pid, ref} = start_view(assigns)
    receive do
      {^ref, assigns} ->
        encoded_pid = pid |> :erlang.term_to_binary() |> Base.encode64()
        signed_pid = Phoenix.Token.sign(assigns.conn, "view", encoded_pid)
        rendered_view = view.__render_template__(template, assigns)
        [
          {:safe, "<script>window.viewPid = \"#{signed_pid}\"</script>"},
          {:safe, "<div id=\"#{signed_pid}\">"},
          rendered_view,
          {:safe, "</div>"},
        ]
    end
  end
  defp start_view(assigns) do
    csrf = Plug.CSRFProtection.get_csrf_token()
    ref = make_ref()
    {:ok, pid} =
      DynamicSupervisor.start_child(
        TurboWeb.DynamicSupervisor,
        {__MODULE__, {{ref, self()}, csrf, assigns}}
      )

    {:ok, pid, ref}
  end

  def handle_info({:DOWN, _ref, :process, pid, _}, %{channel_pid: pid} = state) do
    shutdown_timer = Process.send_after(self(), :timeout, @timeout)
    {:noreply, %{state | shutdown_timer: shutdown_timer}}
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :normal}, state}
  end

  def handle_info(msg, %{assigns: assigns} = state) do
    case state.view_module.handle_info(msg, assigns) do
      {:ok, ^assigns} -> {:noreply, state}
      {:ok, new_assigns} ->
        send_channel(state, {:render, rerender(state, new_assigns)})
        {:noreply, %{state | assigns: new_assigns}}
     end
  end

  def handle_call({:attach, channel_pid}, _, state) do
    if state.shutdown_timer, do: Process.cancel_timer(state.shutdown_timer)
    Process.monitor(channel_pid)
    {:reply, :ok, %{state | channel_pid: channel_pid}}
  end

  def handle_call({:channel_event, event, dom_id, value}, _, %{assigns: assigns} = state) do
    case state.view_module.handle_event(event, dom_id, value, assigns) do
      {:ok, ^assigns} ->
        {:reply, :noop, state}

      {:ok, new_assigns} ->
        {:reply, {:render, rerender(state, new_assigns)}, %{state | assigns: new_assigns}}
    end
  end

  defp rerender(%{view_module: view, view_template: template}, assigns) do
    view.__render_template__(template, assigns)
  end

  defp send_channel(%{channel_pid: nil}, _message), do: :noop
  defp send_channel(%{channel_pid: pid}, message) do
    send(pid, message)
  end
end
