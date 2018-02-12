// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
import "react-phoenix";

import "./custom.js";

import Home from "./components/Home";
import Header from "./components/Header";
import Admin from "./components/Admin";

// Way to call 'Foundation'
var Foundation = require('foundation-sites/dist/js/foundation');

window.Components = {
  Home, Header, Admin,
}

// Quill initialization
document.addEventListener("DOMContentLoaded", () => {
  var quill = new Quill("#editor", { theme: "snow" })
})

$(document).ready($ => {
  $(document).foundation();
})
