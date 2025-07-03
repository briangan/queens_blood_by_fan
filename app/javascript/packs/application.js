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
import "best_in_place"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

$(function() {
  $(".best-in-place-input").best_in_place();

});