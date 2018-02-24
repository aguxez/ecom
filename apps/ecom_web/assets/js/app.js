import "phoenix_html";
import "./stripeForm.js";
// Way to import 'Foundation'
import "foundation-sites/dist/js/foundation";

// SimpleMDE
var SimpleMDE = require("simplemde/dist/simplemde.min.js");

// To make async/await work
require("babel-core/register");
require("babel-polyfill");

$(document).ready($ => {
  // Foundation
  $(document).foundation();

  var simplemde = new SimpleMDE({
    element: $("#product-edit")[0],
    hideIcons: ["image", "guide"]
  })
})
