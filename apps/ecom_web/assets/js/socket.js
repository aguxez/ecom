import {Socket} from "phoenix"

let token = document.querySelector("meta[name=channel_token]").getAttribute("content");
let socket = new Socket("/socket", {params: {token: token}})

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("payments:*", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

let form = document.getElementById("paypal-form");

if (window.location.pathname == "/payments") {
  form.addEventListener("submit", event => {
    event.preventDefault();
    let ser = $("#paypal-form").serializeArray();

    channel.push("form_submit", {form: ser});
  })
}

channel.on("form_resubmit", event => {
  let hid_in = document.createElement("input");

  $("input[name='amount']").remove();


  hid_in.setAttribute("type", "hidden");
  hid_in.setAttribute("name", "amount");
  hid_in.setAttribute("value", event.form.amount.value);

  form.appendChild(hid_in);

  form.submit();
})

export default socket
