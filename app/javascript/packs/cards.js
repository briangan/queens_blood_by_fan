function getMainBoard() {
  let mainBoard = $(".board-wrapper > table > tbody").first();
  window.mainBoard = mainBoard; // For debugging purposes
  return mainBoard;
}
function showBoardNotice(message, type = 'info') {
  var bgClass = 'bg-' + type;
  $("#board_notice").removeClass(bgClass).addClass(bgClass).text(message).css('opacity', 1);
  window.setTimeout(function(){ $("#board_notice").css('opacity', 0); }, 2000);
}

/* Status and questionaire functions ******************/
function isCardAcceptableToTile(card, tile) {
  var isAcceptable = ( card.attr('data-player') == tile.attr('data-player') );
  var msg = (isAcceptable) ? '' : "Currently this tile is not claimed by you.";
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
  var [shouldAccept, msg] = isCardAcceptableToTile( ui.draggable, $(this));
  //console.log("Card dropped " + ui.draggable.attr('id') + " on " + $(this).attr('id') + " => "+ shouldAccept );

  if (shouldAccept) {
    ui.draggable.data('board-tile-id', $(this).attr('id') );
    ui.draggable.draggable( 'disable' );
    //$(this).droppable( 'disable' );
    //ui.draggable.position( { of: $(this), my: 'left top', at: 'left top' } );
    var whichPlayer = ui.draggable.data('player');
    $(this).html('');
    $(ui.draggable).detach().appendTo( $(this) );
    ui.draggable.addClass('card-dropped');
    ui.draggable.removeClass('small-card');

    ui.draggable.draggable( 'option', 'revert', false );

    $("#game_move_card_id").val( ui.draggable.attr('data-card-id') );
    $("#game_move_game_board_tile_id").val( $(this).attr('data-game-board-tile-id') );
    $("#game_move_submit_button").trigger('click'); // $("#game_move_form").trigger('submit');

    $(this).attr('data-claiming-player', whichPlayer ); // If drop onto pawn, would be unnecessary
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
    tile.find(".disabled-icon").removeClass('d-none');
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
  board.find('.center-tile').find(".disabled-icon").addClass('d-none');
  board.find('.center-tile').removeClass('center-tile');
  board.find('.preview-effect-label').each(function(n){ $(this).remove() });
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

// Initialization
$(document).on("turbolinks:load", function() {
  $(".draggable").draggable({ 
    "opacity": 0.35, revert: false,
    snap: ".board-tile", snapMode: "inner", snapTolerance: 30,
    stack: ".card-wrapper div",
    revert: shouldDragRevertDragToTile
  });
  $(".droppable").droppable({
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
  });

  /* $(document).on("dragstart", "card", function (event) {
    console.log("Card dragging " + $(this).attr('id') );
  }); */

  $(document).on("dragstop", ".card", function (event) {
    $(this).children(".bi").addClass('d-none');
  });

  $("*[data-bs-toggle='tooltip'").tooltip();
});