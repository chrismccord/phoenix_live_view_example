defmodule DemoWeb.CounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h1>Payment: <%= @payment_number %></h1>
    </div>
    <script src="//js.stripe.com/v3/"></script>

    <form phx-submit="charge" id="payment-form-<%= @payment_number %>">
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
    <script>StripePayment.setup(<%= @payment_number %>)</script>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, payment_number: 1, token: nil)}
  end

  def handle_event("charge", %{"stripeToken" => _token} = params, socket) do
    IO.inspect(params)
    {:noreply, update(socket, :payment_number, &(&1 + 1))}
  end
end
