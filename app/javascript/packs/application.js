// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import jQuery from "jquery"

// Set globals BEFORE importing plugins
window.jQuery = jQuery
window.$ = jQuery

import "jquery-ui/ui/widgets/draggable"
import "jquery-ui/ui/widgets/droppable"

//import "./controllers"
import * as bootstrap from 'bootstrap'

// These need jQuery and $


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

  $(".best-in-place-input").best_in_place();
  $(".best-in-place").best_in_place();
  $(".best_in_place").best_in_place();
});

// Reload the page if it was loaded from the bfcache (back-forward cache)
$(window).on('load', function(event) {
  if (event.persisted) {
    window.location.reload();
  }
});