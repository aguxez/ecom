import "phoenix_html";
// Way to import 'Foundation'
import "foundation-sites/dist/js/foundation";

var SimpleMDE = require("simplemde/dist/simplemde.min.js")

// Foundation
$(document).foundation();

// SimpleMDE
var editor = new SimpleMDE({
  element: document.getElementById("productEdit"),
  autoDownloadFontAwesome: false,
})

// Stripe form
var stripe = Stripe('pk_test_gytJ3osyEvhIHnKC0PP7dj8C');
var elements = stripe.elements();

var style = {
  base: {
    // Add your base input styles here. For example:
    fontSize: '16px',
    color: "#32325d",
  }
};

// Create an instance of the card Element.
var card = elements.create('card', {style: style});

// Add an instance of the card Element into the `card-element` <div>.
card.mount('#card-element');

// Listening for errors
card.addEventListener('change', function(event) {
  var displayError = document.getElementById('card-errors');
  if (event.error) {
    displayError.textContent = event.error.message;
  } else {
    displayError.textContent = '';
  }
});

// Form intercept
// Create a token or display an error when the form is submitted.
var form = document.getElementById('payment-form');

form.addEventListener('submit', function(event) {
  event.preventDefault();

  stripe.createToken(card).then(function(result) {
    if (result.error) {
      // Inform the customer that there was an error.
      var errorElement = document.getElementById('card-errors');
      errorElement.textContent = result.error.message;
    } else {
      // Send the token to your server.
      stripeTokenHandler(result.token);
    }
  });
});

function stripeTokenHandler(token) {
  // Insert the token ID into the form so it gets submitted to the server
  var form = document.getElementById('payment-form');
  var hiddenInput = document.createElement('input');
  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', 'stripeToken');
  hiddenInput.setAttribute('value', token.id);
  form.appendChild(hiddenInput);

  // Submit the form
  form.submit();
}

