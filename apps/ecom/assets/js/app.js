// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
import "react-phoenix";

import "./custom.js";

import Admin from "./components/Admin";

// Way to call 'Foundation'
var Foundation = require('foundation-sites/dist/js/foundation');

window.Components = {
  Admin,
}

$(document).ready($ => {
  // Foundation
  $(document).foundation();

})
