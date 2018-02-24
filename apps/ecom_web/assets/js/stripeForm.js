"use strict";

// Stripe form
const stripe = Stripe('pk_test_gytJ3osyEvhIHnKC0PP7dj8C');
const elements = stripe.elements();

const style = {
  base: {
    fontSize: "16px",
    color: "#32325d",
  },
};

const card = elements.create("card", {style})

card.mount("#card-element")

// Listening for errors
card.addEventListener("change", ({error}) => {
  const displayError = document.getElementById("card-errors");

  if (error) {
    displayError.textContent = error.message;
  } else {
    displayError.textContent = "";
  }
})

// Form intercept
const form = document.getElementById("payment-form");

form.addEventListener("submit", async (event) => {
  event.preventDefault();

  const {token, error} = await stripe.createToken(card);

  if (error) {
    const errorElement = document.getElementById("card-errors");

    errorElement.textContent = error.message;
  } else {
    stripeTokenHandler(token);
  }
});

const stripeTokenHandler = (token) => {
  const form = document.getElementById("payment-form");
  const hiddenInput = document.createElement("input");

  hiddenInput.setAttribute("type", "hidden");
  hiddenInput.setAttribute("name", "stripeToken");
  hiddenInput.setAttribute("value", token.id);
  form.appendChild(hiddenInput);

  form.submit();
}
