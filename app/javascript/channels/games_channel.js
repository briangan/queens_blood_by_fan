import consumer from "./consumer"
import $ from "jquery"

// Replace GAME_ID with the actual game id, e.g., from a data attribute or JS variable
$(document).on("turbolinks:load", function() {
  const gameId = window.currentGameId || document.querySelector("body").getAttribute("data-game-id");

  if (gameId && gameId != '') {
    // console.log("--> initializing GamesChannel for game " + gameId);
    consumer.subscriptions.create({ channel: "GamesChannel", game_id: gameId }, {
      connected() {
        // Called when the subscription is ready for use on the server
        // console.log(`Connected to GamesChannel for game ${gameId}`);
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        // Handle broadcasted data here
        if (data.action === "game_move_made") {
          // Update the board or notify users as needed
        }
        // General DOM updates w/ selector, so works for any element
        else if (data.action === "update_board" && data.selector && data.html) {
          $(data.selector).html(data.html);

          //console.log("Updated board "+ data.selector + " and given JS:", data.js);
          if (data.js) {
            eval(data.js);
          }
        } 
        else if (data.action === "update_player_and_turn" && data.html) {
          $("#game_current_player_frame").html(data.html);
        } 
        else if (data.action === "update_scores" && data.player_1_score_label && data.player_2_score_label) {
          $("#player_1_row_total_score").html(data.player_1_score_label);
          $("#player_2_row_total_score").html(data.player_2_score_label);
        }
        else if (data.action === "show_completed" && data.html) {
          $("#user_cards_frame").html('');
          $("#game_current_player_frame").html('');
          $("#game_actions_panel_frame").html('');
          $("#game_current_player_frame").html(data.html);
        } 
      } // received
    });
  }
});