defmodule DemoWeb.ChatLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h3>Small chat room</h3>
      <pre><%= @message %></pre>
      <form phx-submit="send">
      <input type="text" name="message" placeholder="some message" value=<%= @value %>></input>
      </form>
    </div>
    """
  end

  def mount(_session, socket) do
    Phoenix.PubSub.subscribe(Demo.PubSub, "message")
    Phoenix.PubSub.broadcast(Demo.PubSub, "message", {:ask})
    {:ok,
     assign(socket, %{
       message: "hello",
       value: "",
     })}
  end

  def handle_event("send", %{"message" => message}, socket = %{assigns: %{message: old_message}}) do
    Phoenix.PubSub.broadcast(Demo.PubSub, "message", {:set, old_message <> "\n" <> message})
    {:noreply,
      assign(socket, %{message: message, value: ""})
    }
  end

  def handle_info({:set, message}, socket) do
    {:noreply,
      assign(socket, message: message)
    }
  end

  def handle_info({:ask}, socket = %{assigns: %{message: message}}) do
    Phoenix.PubSub.broadcast(Demo.PubSub, "message", {:set, message})
    {:noreply, socket}
  end

end
