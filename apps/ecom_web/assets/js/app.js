import "phoenix_html";
import "./socket";
import {populateCountries, populateStates} from "./countries";

// Way to import 'Foundation'
import "foundation-sites/dist/js/foundation";

var SimpleMDE = require("simplemde/dist/simplemde.min.js")

function get_location() { return(window.location.pathname + window.location.search) }

// Foundation
$(document).foundation();

// SimpleMDE
var editor = new SimpleMDE({
  element: document.getElementById("productEdit"),
  autoDownloadFontAwesome: false,
})

if (get_location() == "/payments?proc_first=true") {
  populateCountries("country", "state");
  populateStates("country", "state");
}
