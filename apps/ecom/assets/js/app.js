// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
import "react-phoenix";

import "./custom.js";

import Admin from "./components/Admin";

var SimpleMDE = require("simplemde/dist/simplemde.min.js");

// Way to import 'Foundation'
import "foundation-sites/dist/js/foundation";

window.Components = {
  Admin,
}

$(document).ready($ => {
  // Foundation
  $(document).foundation();

  var simplemde = new SimpleMDE({
    element: $("#product-edit")[0],
    hideIcons: ["image", "guide"]
  })
})
