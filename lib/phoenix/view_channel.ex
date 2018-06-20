defmodule Phoenix.ViewChannel do
  use Phoenix.Channel

  def join(_, %{"view" => token}, socket) do
    case Phoenix.Token.verify(socket, "view", token, max_age: 1209600) do
      {:ok, encoded_pid} ->
        pid = encoded_pid |> Base.decode64!() |> :erlang.binary_to_term()

        case Phoenix.TurboView.attach(pid) do
          :ok ->
            new_socket =
              socket
              |> assign(:view_pid, pid)
              |> assign(:view_id, token)

            {:ok, new_socket}

          {:error, {:noproc, _}} ->
            {:error, %{reason: "noproc"}, socket}
        end

      {:error, _reason} ->
        {:error, %{reason: :bad_view}, socket}
    end
  end

  def handle_info({:render, content}, socket) do
    push_render(socket, content)
    {:noreply, socket}
  end

  def handle_in("event", %{"id" => id, "value" => raw_value, "event" => event, "type" => type}, socket) do
    value = decode(type, raw_value)
    case GenServer.call(socket.assigns.view_pid, {:channel_event, event, id, value}) do
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

  defp push_render(socket, {:safe, content}) do
    push(socket, "render", %{id: socket.assigns.view_id,
                             html: IO.iodata_to_binary(content)})
  end
end
