import "phoenix_html";
import "./socket";
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

