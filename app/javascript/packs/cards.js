function getMainBoard() {
  let mainBoard = $(".board-wrapper > table > tbody").first();
  window.mainBoard = mainBoard;
  return mainBoard;
}
function showBoardNotice(message, type = 'info') {
  var bgClass = 'bg-' + type;
  $("#board_notice").removeClass(bgClass).addClass(bgClass).text(message).css('opacity', 1);
  window.setTimeout(function(){ $("#board_notice").css('opacity', 0); }, 2000);
}
function getSelectedCard() {
  return $("#user_cards_wrapper .card-selected")[0];
}
window.getMainBoard = getMainBoard;
window.showBoardNotice = showBoardNotice;
window.droppableOptions = droppableOptions;
window.setupCardInteractions = setupCardInteractions;
window.setupTileInteractions = setupTileInteractions;
let MAX_CARDS_PER_DECK = 15; // Best to refer this to backend constant
window.MAX_CARDS_PER_DECK = MAX_CARDS_PER_DECK;

/* Status and questionaire functions ******************/
function isCardAcceptableToTile(card, tile) {
  var isAcceptable = ( card.attr('data-player') == tile.attr('data-player') );
  var msg = (isAcceptable) ? '' : "Currently this tile is not claimed by you.";
  var currentTurnUserId = $("#game_current_turn_user_id").val();
  if (isAcceptable && currentTurnUserId && currentTurnUserId != '') {
    isAcceptable = (card.attr('data-player') == currentTurnUserId);
    msg = (isAcceptable) ? '' : "Currently it is not your turn to make move.";
  }
  // check card's pawn_rank vs tile's pawn_value
  if (isAcceptable && card.data('pawn-rank') && tile.data('pawn-value')) {
    isAcceptable = ( parseInt(card.data('pawn-rank')) <= parseInt(tile.data('pawn-value')) );
    msg = (isAcceptable) ? '' : "This card requires the tile w/ " + card.data('pawn-rank') + "+ pawns"
  }
  return [isAcceptable, msg];
}
function shouldDragRevertDragToTile() {
  //////////console.log("Should revert? " + $(this).attr('id') + " w/ " + $(this).attr('class') );
  return !$(this).hasClass('card-dropped');
}

/* Action Handlers *************************************/
function dropCardHandler(event, ui) {
  placedCardOntoTile(ui.draggable, $(this));
}

function placedCardOntoTile(card, tile) {
  var [shouldAccept, msg] = isCardAcceptableToTile( card, tile);
  //console.log("Card dropped " + card.attr('id') + " on " + tile.attr('id') + " => "+ shouldAccept );

  if (shouldAccept) {
    card.data('board-tile-id', tile.attr('id') );
    if (card.hasClass('draggable')) {
      card.draggable( 'disable' );
      //tile.droppable( 'disable' );
      //ui.draggable.position( { of: tile, my: 'left top', at: 'left top' } );
    }
    var whichPlayer = card.data('player');
    tile.html('');
    card.detach().appendTo( tile );
    card.addClass('card-dropped');
    card.removeClass('small-card');

    if (card.hasClass('draggable')) {
      card.draggable( 'option', 'revert', false );
    }
    $(".floating-card").remove();

    $("#game_move_card_id").val( card.attr('data-card-id') );
    $("#game_move_game_board_tile_id").val( tile.attr('data-game-board-tile-id') );
    $("#game_move_submit_button").trigger('click'); // $("#game_move_form").trigger('submit');

    tile.attr('data-claiming-player', whichPlayer ); // If drop onto pawn, would be unnecessary
  } else {
    // console.log("> Cannot drop this card here!");
    showBoardNotice( (msg == '') ? "Cannot drop this card here!" : msg, 'warning');
  }
  resetHLTiles();
}

/* Dry run that only renders the effects of the card placement.
* Iterates over the pawn-tiles and affected-tiles of the card to highlight the tiles that would be affected.
*/
function previewCardPlacementEffect(board, tile, card) {
  var shouldAccept = isCardAcceptableToTile( card, tile );
  //////////// console.log("Card hover - preview " + card.attr('data-player') + " on " + tile.attr('data-player') + " => "+ shouldAccept );
  if (!shouldAccept) {
    tile.find(".disabled-overlay").removeClass('d-none');
    return; 
  }

  var pawnTiles = card.data('pawn-tiles');
  var affectedTiles = card.data('affected-tiles');
  var abilities = card.data('ability-effects');
  if (typeof(abilities) == 'string' && abilities !='' ){ 
    abilities = eval(abilities); 
  }
  
  tile.addClass('center-tile');
  var tileX = parseInt(tile.data('tile-position').split(',')[0]);
  var tileY = parseInt(tile.data('tile-position').split(',')[1]);
  if (typeof(pawnTiles) == 'string'){ pawnTiles = eval(pawnTiles); }
  pawnTiles.forEach(function(pawnTile) {
    var col = tileX + pawnTile[0];
    var row = tileY + pawnTile[1];
    var targetTile = board.find('.board-tile[data-tile-position="' + col + ',' + row + '"]');
    if (targetTile.length > 0) {
      targetTile.addClass('highlight-tile');
      targetTile.children('.card').addClass('highlight-tile');
    }
  } );
  if (typeof(affectedTiles) == 'string'){ affectedTiles = eval(affectedTiles); }
  affectedTiles.forEach(function(aTile) {
    var col = tileX + aTile[0];
    var row = tileY + aTile[1];
    var targetTile = board.find('.board-tile[data-tile-position="' + col + ',' + row + '"]');
    if (targetTile.length > 0) {
      abilities.forEach(function(ability) {
        targetTile.addClass('highlight-tile');
        targetTile.children('.card').addClass('highlight-tile');
        // console.log("Preview ability effect to " + targetTile.attr('id') + " => " + ability['action_typeß'] );
        previewVisualEffectTo(tile, targetTile, ability);
      });
    }
  } );
}
function resetHLTiles() {
  let board = getMainBoard();
  board.find('.highlight-tile').removeClass('highlight-tile');
  board.find('.center-tile').find(".disabled-overlay").addClass('d-none');
  board.find('.center-tile').removeClass('center-tile');
  board.find('.preview-effect-label').each(function(n){ $(this).remove() });
  board.find(".disabled-overlay").addClass('d-none');
}
/* 
* Renders the visual effect of the card placement on the target tile based on ability.
*/
function previewVisualEffectTo(sourceTile, targetTile, ability) 
{
  if (ability['action_type'] == 'power_up') {
    $(targetTile.children()[0]).append("<h3 class='preview-effect-label powerup-effect'> +" + ability['action_value'] + "</h3>")
  } else if (ability['action_type'] == 'power_down') {
    $(targetTile.children()[0]).append("<h3 class='preview-effect-label powerdown-effect'> -" + ability['action_value'] + "</h3>")
  }
}

function syncCardSelectionToInputs(){
  var cardIds = [];
  $('#deck_cards_wrapper > *[data-card-id]').each(function(index, element) {
    var cardId = $(element).data('card-id');
    cardIds.push(cardId);
  });
  $("#deck_form input[name='card_ids[]']").each(function(index, element) {
    $(element).val( cardIds[index] || '' );
  });
}
function showDetailOfCardInCanvas() {
  var s = "<img src='" + $(this).data('image-url') + "' class='img-fluid' />";
  if ($(this).data('card-id')) {
    s += "<div class='text-center'><a href=\'/cards/" + $(this).data('card-id') + "'><label class='bi bi-info-square-fill text-primary text-medium'/> Show detail of card</a></div>";
  }
  $('#detail_offcanvas').find('.offcanvas-body').html(s);
}
function showDetailLinkOfCard() {
    $(this).find('.card-detail-image').removeClass('d-none');
}
function hideDetailLinkOfCard() {
  setTimeout(() => {
    $(this).find('.card-detail-image').addClass('d-none');
  }, 3000);
}

function clickToUserCardHandler(event) 
{
  if ($(this).hasClass('card-selected') ) // deselect current card
  {
    $(this).removeClass('card-selected');
    $(this).addClass('small-card');
    $(".floating-card").remove();
  } 
  else {
    // Unselect all other cards
    $("#user_cards_wrapper .card-selected").removeClass('card-selected');
    $("#user_cards_wrapper .card-selectable").addClass('small-card');
    $(".floating-card").remove();
    // select this card
    $(this).addClass('card-selected');
    $(this).removeClass('small-card');

    // Need selected card to jump over to board and float this card at top of window's scroll position
    var boardOffset = $("#board_table").offset();
    var floatCard = $(this).clone().addClass('floating-card').css({
      position: 'absolute',
      top: boardOffset.top - 20,
      left: boardOffset.left - 20,
      zIndex: 1000
    }).appendTo("body");
    floatCard.find(".card-detail-image").html("");
    // scroll to floating card
    $('html, body').animate({
      scrollTop: floatCard.offset().top - 20
    }, 300);

    var tileSelector = ".board-tile[data-player='" + $(this).data('player') +"']";
    $(tileSelector).on('mouseover', function(event) {
        var cardDropped = $(this).find(" .card[data-card-id]");
        if (cardDropped.length == 0) // no-card placed
        {
          $(this).addClass('center-tile');
          previewCardPlacementEffect( getMainBoard(), $(this), $(".card-selected") );
        } else {
          $(this).find(".disabled-overlay").removeClass('d-none');
        }
      });
    $(tileSelector).on('mouseout', function(event) {
      $(this).removeClass('center-tile');
      resetHLTiles();
    });
  }
}

/* User deck cards handlers ***********************************/
function addCardToSelection(event) {
  const userCardId = $(this).data('user-card-id');
  const cardId = $(this).data('card-id');
  var quantityInput = $(this).siblings('*[data-quantity]');
  if (quantityInput) {
    var quantity = parseInt(quantityInput.text()) || 0;
    var countOfCardsInDeck = $("#deck_cards_wrapper > *[data-card-id]").length;
    if (quantity < 1) {
      quantityInput.addClass('warning-short-blink');
    } else if (countOfCardsInDeck >= MAX_CARDS_PER_DECK) {
      $("#max_cards_per_deck_note").addClass('warning-short-blink');
      alert("You can only have " + MAX_CARDS_PER_DECK + " cards in your deck.");
    } else {
      quantity -= 1;
      quantityInput.text(quantity);
      var userCard = $("#user_card_"+ userCardId).clone();
      $(userCard).prop('id', 'user_card_clone_' + userCardId);
      $(userCard).attr('data-user-card-id', '');
      $(userCard).removeClass('card-selectable');
      var actionRow = $(userCard).children();
      $(actionRow).children('.user-card-quantity-input').addClass('d-none');
      $(actionRow).children('.user-card-add-button').addClass('d-none');
      $(actionRow).children('.user-card-remove-button').removeClass('d-none');
      $(userCard).appendTo($("#deck_cards_wrapper"));
      $("#user_card_clone_" + userCardId + " > .card-actions-row > .user-card-remove-button").click( removeCardFromSelection );
    }
    $("#user_cards_wrapper > *[data-user-card-id='" + userCardId + "']").css('opacity', (quantity < 1) ? '0.5' : '1');

    syncCardSelectionToInputs();
  }
}

function removeCardFromSelection() {
  let card = $(this).parent().parent();
  const cardId = $(card).data('card-id');
  let userCard = $("#user_cards_wrapper > *[data-card-id='" + cardId + "']");
  if (userCard) {
    var quantityInput = $("#user_cards_wrapper > *[data-card-id='" + cardId + "'] *[data-quantity]");
    if (quantityInput.length > 0) {
      var quantity = parseInt( $(quantityInput).text()) || 0;
      quantity++;
      $(quantityInput).text(quantity);
      $("#user_cards_wrapper > *[data-card-id='" + cardId + "']").css('opacity', (quantity < 1) ? '0.5' : '1');
    }
    $(card).detach().remove();
    // Even after removal, the #user_cards_wrapper
    syncCardSelectionToInputs();
  }
}

/* Load functions ########################################### */

function setupCardInteractions() {
  $(".draggable").draggable({ 
    "opacity": 0.35, revert: false,
    snap: ".board-tile", snapMode: "inner", snapTolerance: 30,
    stack: ".card-wrapper div",
    revert: shouldDragRevertDragToTile
  });

  $(".card-selectable").on('click', clickToUserCardHandler);

  $(".card-detail-link[data-image-url]").on('click', showDetailOfCardInCanvas );
  $(".card[data-card-id]").on('mouseover', showDetailLinkOfCard );
  $(".card[data-card-id]").on('mouseout', hideDetailLinkOfCard );
}

function droppableOptions() {
  return {
    hoverClass: "card-drop-hover",
    accept: '.card',
    drop: dropCardHandler, 
    over: function(event, ui) {
      /////// console.log("Card over " + $(this).attr('id'));
      //$(ui.draggable).children(".bi").removeClass('d-none');
      $(this).addClass('center-tile');
      previewCardPlacementEffect( getMainBoard(), $(this), $(ui.draggable) );
    },
    out: function(event, ui) {
      /////// console.log("Card out " + $(this).attr('id'));
      //$(ui.draggable).children(".bi").addClass('d-none');
      resetHLTiles();
    }
  }
}

function setupTileInteractions(){
  var selectedCard = getSelectedCard();
  if (selectedCard) {
    placedCardOntoTile( $(selectedCard), $(this));
  }
}

function setupBoardInteractions() {
  
  $(".droppable").droppable(droppableOptions());

  /* $(document).on("dragstart", "card", function (event) {
    console.log("Card dragging " + $(this).attr('id') );
  }); */

  $(document).on("dragstop", ".card", function (event) {
    $(this).children(".bi").addClass('d-none');
  });

  $('.user-card-add-button').on('click', addCardToSelection );
  $('.user-card-remove-button').on('click', removeCardFromSelection );
  $("#board_table .board-tile[data-player]").on('click', setupTileInteractions);

  window.showDetailOfCardInCanvas = showDetailOfCardInCanvas;
  window.showDetailLinkOfCard = showDetailLinkOfCard;
  window.hideDetailLinkOfCard = hideDetailLinkOfCard;

  syncCardSelectionToInputs();

  $("*[data-bs-toggle='tooltip'").tooltip();
}

// Initialization
$(document).on("turbolinks:load", function(){
  setupCardInteractions();
  setupBoardInteractions();

  $("*[data-bs-toggle='tooltip'").tooltip();
});