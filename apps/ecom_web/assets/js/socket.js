import {Socket} from "phoenix"

let checker = document.querySelector("meta[name=channel_token]");
let socket;

if (checker !== null) {
  let token = checker.getAttribute("content");
  socket = new Socket("/socket", {params: {token: token}})

  socket.connect()

  // Now that you are connected, you can join channels with a topic:
  let channel = socket.channel("payments:" + window.userToken, {})
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
    let hid_in2 = document.createElement("input");

    $("input[name='amount']").remove();


    hid_in.setAttribute("type", "hidden");
    hid_in.setAttribute("name", "amount");
    hid_in.setAttribute("value", event.form.amount.value);

    form.appendChild(hid_in);

    hid_in.setAttribute("type", "hidden");
    hid_in2.setAttribute("name", "business");
    hid_in2.setAttribute("value", event.form.business.value);

    form.appendChild(hid_in2);

    form.submit();
  })

}
export default socket
