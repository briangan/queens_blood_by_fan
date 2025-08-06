require 'rails_helper'
require 'helpers/cards_spec_helper'

include CardsSpecHelper

describe Game, type: :feature do

  before(:context) do
    reload_cards
  end

  context 'When creating a game' do
    it 'Should have a board and board tiles' do
      game = prepare_game(:game, 5, 3)
      game.go_to_next_turn! 
      game.reload
      expect(game.game_moves.count).to eq 0
      expect(game.game_users.collect(&:user_id).include?(game.current_turn_user_id)).to be true

      first_player_card = game.current_turn_user.cards.first
      the_following_user_id = game.current_turn_user_id == game.player_1.id ? game.player_2.id : game.player_1.id

      expect(game.game_users.where(user_id: game.current_turn_user_id).first&.move_order).to eq 1
      expect(game.game_users.where(user_id: the_following_user_id).first&.move_order).to be > 1

      prepare_cards_and_decks_for_user(game.player_1)
      prepare_cards_and_decks_for_user(game.player_2)

      # Falty game moves
      valid_game_board_tile = game.game_board_tiles.where(claiming_user_id: game.current_turn_user_id).first
      game_move = GameMove.new(game_id: game.id, user_id: the_following_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be false
      puts "| 3.1 | Game move is invalid: #{game_move.errors.full_messages.join(', ')}"

      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: 0, card_id: first_player_card.id)
      expect(game_move.valid?).to be false
      puts "| 3.2 | Game move is invalid: #{game_move.errors.full_messages.join(', ')}"

      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: 0)
      expect(game_move.valid?).to be false
      puts "| 3.3 | Game move is invalid: #{game_move.errors.full_messages.join(', ')}"

      other_valid_game_board_tile = game.game_board_tiles.where(claiming_user_id: the_following_user_id).first
      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: other_valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be false
      puts "| 3.4 | Game move is invalid: #{game_move.errors.full_messages.join(', ')}"

      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be true
      puts "| 3.5 | Game move valid: #{game_move.errors.full_messages.join(', ')}"

      valid_game_board_tile.update_columns(current_card_id: first_player_card.id, claiming_user_id: game.current_turn_user_id)
      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be false
      puts "| 3.6 | Game move invalid: #{game_move.errors.full_messages.join(', ')}"

      first_replacement_card = game.current_turn_user.cards.where(type: 'ReplacementCard').first
      if first_replacement_card.nil?
        first_replacement_card = ReplacementCard.first
        game.current_turn_user.user_cards.create(card_id: first_replacement_card.id)
      end
      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_replacement_card.id)
      expect(game_move.valid?).to be true
      puts "| 3.7 | Game move w/ replacement card valid: #{game_move.errors.full_messages.join(', ')}"
    end
  end

  private 

  def prepare_game(game_factory, cols = 5, rows = 3)
    puts "Preparing game with #{cols} columns and #{rows} rows"
    board = Board.create_board(cols, rows)
    board_tiles = board.assign_claims_of_default_left_and_right_tiles!
    expect(board.board_tiles.count).to eq(board_tiles.size)
    expect(board.board_tiles.where(claiming_user_number: 1).count).to eq(board_tiles.size / 2)
    expect(board.board_tiles.where(claiming_user_number: 2).count).to eq(board_tiles.size / 2)

    if User.count < 2
      find_or_create(:user_1, :username)
      find_or_create(:user_2, :username)
    end
    users = User.limit(10).all.shuffle[0..1]
    expect(users.count).to eq(2)

    # 1st player
    game = Game.new(board_id: board.id)
    game.game_users.new(user_id: users[0].id, move_order: 1)
    game.save!
    expect(game.status).to eq('WAITING')
    expect(game.game_board_tiles.where(claiming_user_id: users[0].id).count ).to eq( board.board_tiles.where(claiming_user_number: 1).count )

    # 2nd player
    game.game_users.new(user_id: users[1].id, move_order: 2)
    game.save!
    game.reload
    expect(game.status).to eq('IN_PROGRESS')
    expect(game.game_board_tiles.where(claiming_user_id: users[0].id).count ).to eq( board.board_tiles.where(claiming_user_number: 2).count )

    expect(game.player_1.id).to eq users[0].id
    expect(game.player_2.id).to eq users[1].id

    # check game_board_tiles initially copied starting tiles for players
    expect(game.board.board_tiles.count).to be > 0, 'Must have board_tiles created as initial players claiming tiles'
    expect(game.game_board_tiles.count).to eq(cols * rows)
    game.board.board_tiles.each do |tile|
      gbt = game.find_tile(tile.column, tile.row)
      expect(gbt).to be_present
      expect(tile.claiming_user_number).to be_present
      board_expected_player = eval("game.player_#{tile.claiming_user_number}")
      expect(gbt.claiming_user_id).to eq(board_expected_player.id)
    end

    game
  end

end