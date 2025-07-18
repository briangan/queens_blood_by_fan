//= require best_in_place
//= require best_in_place.jquery-ui
//= require best_in_place.purr

$(document).on("turbolinks:load", function() {
  $(".best-in-place-input").best_in_place();
  $(".best-in-place").best_in_place();
});