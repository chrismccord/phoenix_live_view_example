import css from "../css/app.css";
import "phoenix_html"
// import {LiveSocket, debug} from "./phoenix_live_view"
import {LiveSocket, debug} from "phoenix_live_view"

// let liveSocket = new LiveSocket("/live", {viewLogger: debug})
let liveSocket = new LiveSocket("/live", {})
liveSocket.connect()
window.liveSocket = liveSocket

liveSocket.socket.onOpen(() => {
    // Create a Stripe client.
    var stripe = Stripe('pk_test_TYooMQauvdEDq54NiTphI7jx');

    // Create an instance of Elements.
    var elements = stripe.elements();

    // Custom styling can be passed to options when creating an Element.
    // (Note that this demo uses a wider set of styles than the guide below.)
    var style = {
      base: {
        color: '#32325d',
        fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
        fontSmoothing: 'antialiased',
        fontSize: '16px',
        '::placeholder': {
          color: '#aab7c4'
        }
      },
      invalid: {
        color: '#fa755a',
        iconColor: '#fa755a'
      }
    };

    // Create an instance of the card Element.
    let wasSuccessful = false;
    var card = elements.create('card', {style: style});

    // Add an instance of the card Element into the `card-element` <div>.
    card.mount('#card-element');

    window.card = card
    // Handle real-time validation errors from the card Element.
    card.addEventListener('change', function(event) {
      var displayError = document.getElementById('card-errors');
      if (event.error) {
        displayError.textContent = event.error.message;
      } else {
        displayError.textContent = '';
      }
    });

    // Handle form submission.
    var form = document.getElementById('payment-form');
    form.addEventListener('submit', function(event) {
      if(wasSuccessful){ return true }

      event.preventDefault();
      event.stopImmediatePropagation();

      stripe.createToken(card).then(function(result) {
        if (result.error) {
          console.log(result.error)
          // Inform the user if there was an error.
          var errorElement = document.getElementById('card-errors');
          errorElement.textContent = result.error.message;
        } else {
          wasSuccessful = true
          console.log("success", result)
          // Send the token to your server.
          stripeTokenHandler(form, event, result.token);
        }
      });
    });

    // Submit the form with the token ID.
    function stripeTokenHandler(form, event, token) {
      // Insert the token ID into the form so it gets submitted to the server
      var form = document.getElementById('payment-form');
      var hiddenInput = document.createElement('input');
      hiddenInput.setAttribute('type', 'hidden');
      hiddenInput.setAttribute('name', 'stripeToken');
      hiddenInput.setAttribute('value', token.id);
      form.appendChild(hiddenInput);

      // Submit the form

      form.dispatchEvent(event)
    }

})
