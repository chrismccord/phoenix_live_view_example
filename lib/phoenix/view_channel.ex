defmodule Phoenix.ViewChannel do
  use Phoenix.Channel

  def join(_, %{"view" => token}, socket) do
    case Phoenix.Token.verify(socket, "view", token, max_age: 1209600) do
      {:ok, encoded_pid} ->
        pid = encoded_pid |> Base.decode64!() |> :erlang.binary_to_term()
        _ref = Process.monitor(pid)

        case Phoenix.LiveView.attach(pid) do
          :ok ->
            new_socket =
              socket
              |> assign(:view_pid, pid)
              |> assign(:view_id, token)

            {:ok, new_socket}

          {:error, {:noproc, _}} ->
            {:error, %{reason: "noproc"}}
        end

      {:error, _reason} ->
        {:error, %{reason: :bad_view}}
    end
  end

  def handle_info({:DOWN, _, :process, pid, reason}, %{assigns: %{view_pid: pid}} = socket) do
    IO.inspect({:DOWN, reason})
    {:stop, :normal, socket}
  end
  def handle_info({:render, content}, socket) do
    push_render(socket, content)
    {:noreply, socket}
  end

  def handle_info({:redirect, opts}, socket) do
    push_redirect(socket, opts)
    {:noreply, socket}
  end

  def handle_in("event", %{"id" => id, "value" => raw_value, "event" => event, "type" => type}, socket) do
    value = decode(type, raw_value)
    case GenServer.call(socket.assigns.view_pid, {:channel_event, event, id, value}) do
      {:redirect, opts} ->
        push_redirect(socket, opts)
      {:render, content} ->
        push_render(socket, content)
      :noop -> :noop
    end
    {:noreply, socket}
  end
  defp decode("form", url_encoded) do
    Plug.Conn.Query.decode(url_encoded)
  end
  defp decode(_, value), do: value

  defp push_render(socket, content) when is_list(content) do
    push(socket, "render", %{id: socket.assigns.view_id,
                             html: IO.iodata_to_binary(content)})
  end
  defp push_render(socket, content) when is_binary(content) do
    push(socket, "render", %{id: socket.assigns.view_id, html: content})
  end

  defp push_redirect(socket, opts) do
    push(socket, "redirect", %{to: Keyword.fetch!(opts, :to),
                               flash: flash_token(socket, opts[:flash])})
  end
  defp flash_token(_socket, nil), do: nil
  defp flash_token(socket, %{} = flash) do
    Phoenix.Token.sign(socket, "phoenix flash", Phoenix.json_library().encode!(flash))
  end
end
