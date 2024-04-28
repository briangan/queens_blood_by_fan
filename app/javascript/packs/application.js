// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import jQuery from "jquery"
import "jquery-ui/ui/widgets/draggable"
import "jquery-ui/ui/widgets/droppable"
//import "./controllers"
import * as bootstrap from 'bootstrap'

Rails.start()
Turbolinks.start()
ActiveStorage.start()
window.jQuery = jQuery
window.$ = jQuery


$(function() {
  $(".draggable").draggable({ containment:"#board-wrapper", "opacity": 0.35, snap: ".board-spot", snapMode: "inner", snapTolerance: 20 });
});

$(document).on("dragstart", "card", function (event) {
  console.log("Card dragging " + $(this).attr('id') );

});
$(document).on("dragstop", "card", function (event) {
  console.log("Card dragged " + $(this).attr('id') );

});