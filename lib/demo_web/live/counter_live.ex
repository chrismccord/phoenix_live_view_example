defmodule DemoWeb.CounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h1>The count is: <%= @val %></h1>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    <script src="//js.stripe.com/v3/"></script>

    <%= if @token do %>
      <h3>Payment successful <%= @token %></h3>
    <% else %>
      <form phx-submit="charge" id="payment-form">
        <div class="form-row">
          <label for="card-element">
            Credit or debit card
          </label>
          <div id="card-element" phx-ignore>
            <!-- A Stripe Element will be inserted here. -->
          </div>

          <!-- Used to display form errors. -->
          <div id="card-errors" role="alert" phx-ignore></div>
        </div>

        <button>Submit Payment</button>
      </form>
    <% end %>
    <script>StripePayment.setup("#card-element")</script>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, val: 0, token: nil)}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end
  def handle_event("charge", %{"stripeToken" => token}, socket) do
    {:noreply, assign(socket, token: token)}
  end
end
