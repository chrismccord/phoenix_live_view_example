defmodule Phoenix.TurboView.Server do
  use GenServer

  @timeout 10_000

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  def attach(pid) do
    try do
      GenServer.call(pid, {:attach, self()})
    catch :exit, reason -> {:error, reason}
    end
  end

  def init({{ref, request_pid}, view, template, csrf, assigns}) do
    Process.put(:plug_masked_csrf_token, csrf)

    assigns
    |> view.init()
    |> configure_init(view, template, {ref, request_pid})
  end
  defp configure_init({:ok, new_assigns}, view, template, {ref, request_pid}) do
    configure_init({:ok, new_assigns, []}, view, template, {ref, request_pid})
  end
  defp configure_init({:ok, new_assigns, opts}, view, template, {ref, request_pid}) do
    shutdown_timer = Process.send_after(self(), :attach_timeout, @timeout)
    state = %{
      view_module: view,
      view_template: template,
      assigns: new_assigns,
      channel_pid: nil,
      shutdown_timer: shutdown_timer,
      timeout: opts[:timeout] || @timeout,
    }
    send(request_pid, {ref, rerender(state, new_assigns)})

    {:ok, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, %{channel_pid: pid} = state) do
    {:stop, :normal, state}
  end

  def handle_info(:attach_timeout, state) do
    {:stop, :normal, state}
  end

  def handle_info(msg, %{assigns: assigns} = state) do
    case state.view_module.handle_info(msg, assigns) do
      {:ok, ^assigns} -> {:noreply, state}
      {:ok, new_assigns} ->
        send_channel(state, {:render, rerender(state, new_assigns)})
        {:noreply, %{state | assigns: new_assigns}}
      {:stop, {:redirect, opts}, new_assigns} ->
        send_channel(state, {:redirect, opts})
        {:stop, :normal, %{state | assigns: new_assigns}}
     end
  end

  def handle_call({:attach, channel_pid}, _, state) do
    if state.shutdown_timer, do: Process.cancel_timer(state.shutdown_timer)
    Process.monitor(channel_pid)
    {:reply, :ok, %{state | channel_pid: channel_pid, shutdown_timer: nil}}
  end

  def handle_call({:channel_event, event, dom_id, value}, _, %{assigns: assigns} = state) do
    event
    |> state.view_module.handle_event(dom_id, value, assigns)
    |> handle_event_result(assigns, state)
  end
  defp handle_event_result({:ok, unchanged_assigns}, unchanged_assigns, state) do
    {:reply, :noop, state}
  end
  defp handle_event_result({:ok, new_assigns}, _original_assigns, state) do
    {:reply, {:render, rerender(state, new_assigns)}, %{state | assigns: new_assigns}}
  end
  defp handle_event_result({:stop, {:redirect, opts}, assigns}, _original_assigns, state) do
    {:stop, :normal, {:redirect, opts}, %{state | assigns: assigns}}
  end

  def terminate(reason, state) do
    {:ok, new_assigns} = state.view_module.terminate(reason, state)
    {:ok, %{state | assigns: new_assigns}}
  end

  defp rerender(%{view_module: view, view_template: template}, assigns) do
    view.__render_template__(template, assigns)
  end

  defp send_channel(%{channel_pid: nil}, _message), do: :noop
  defp send_channel(%{channel_pid: pid}, message) do
    send(pid, message)
  end
end
