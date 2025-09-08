// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import jQuery from "jquery"

// Set globals BEFORE importing plugins
window.jQuery = jQuery
window.$ = jQuery

// Also set the global scope for module environments
if (typeof global !== 'undefined') {
  global.jQuery = jQuery
  global.$ = jQuery
}

// Import jQuery UI and plugins after jQuery is set up
import "jquery-ui/ui/widgets/draggable"
import "jquery-ui/ui/widgets/droppable"
import "jquery-ui/ui/widgets/datepicker"
import "../best_in_place"
import "../best_in_place.jquery-ui"
import "../best_in_place.purr"

//import "./controllers"
import * as bootstrap from 'bootstrap'

// These need jQuery and $
import "channels"


Rails.start()
Turbolinks.start()
ActiveStorage.start()

$(document).on("turbolinks:load", function() {
  // This disables Turbo prefetching for hover over links with data-turbo-prefetch
  document.querySelectorAll("a[data-turbo-prefetch]").forEach(link => {
    link.removeAttribute("data-turbo-prefetch");
  });
  document.addEventListener("mouseover", function(e) {
    if (e.target.tagName === "A") {
      e.target.setAttribute("data-turbo-prefetch", "false");
    }
  }, true);

  // Initialize best_in_place
  if (typeof $.fn.best_in_place !== 'undefined') {
    $(".best_in_place").best_in_place();
    $(".best-in-place").best_in_place();
    $(".best-in-place-input").best_in_place();
  }
  $("*[data-bs-toggle='tooltip']").tooltip();
});

// Reload the page if it was loaded from the bfcache (back-forward cache)
$(window).on('load', function(event) {
  if (event.persisted) {
    window.location.reload();
  }
});