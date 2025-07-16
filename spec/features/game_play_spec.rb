require 'rails_helper'
require 'helpers/cards_spec_helper'

include CardsSpecHelper

describe Game, type: :feature do

  before(:all) do
    reload_cards
  end

  context 'When creating a game' do
    it 'Should have a board and board tiles' do
      game = prepare_game(:game, 5, 3)

      prepare_cards_and_decks_for_user(game.player_1)
      prepare_cards_and_decks_for_user(game.player_2)
      
      # check_pawn_rank_and_claiming_user_id(game)
    end
  end

  private 

  def prepare_game(game_factory, cols = 5, rows = 3)
    puts "Preparing game with #{cols} columns and #{rows} rows"
    board = Board.create_board(cols, rows)

    if User.count < 2
      find_or_create(:user_1, :username)
      find_or_create(:user_2, :username)
    end
    users = User.limit(10).all.shuffle[0..1]
    expect(users.count).to eq(2)

    # 
    game = Game.new(board_id: board.id)
    game.game_users.new(user_id: users[0].id, move_order: 1)
    game.game_users.new(user_id: users[1].id, move_order: 2)
    game.save!

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

  ##
  # Ensure first column and last column are claimed by the respective users.
  def check_pawn_rank_and_claiming_user_id(game)
    player1 = game.player_1
    player2 = game.player_2
    pick = game.board.range_to_pick(game.board.rows)
    game.game_board_tiles.each do |tile|
      if tile.column == 1 && pick.include?(tile.row)
        expect(tile.claiming_user_id).to eq(player1.id)
      elsif tile.column == board.columns.size && pick.include?(tile.row)
        expect(tile.claiming_user_id).to eq(player2.id)
      end
    end
  end

  # Check the range of rows that can be picked for a given number of rows.
  def check_range_to_pick(board)
    1.upto(4) do |i|
      expect(board.range_to_pick(i)).to eq(1..i)
    end
    5.upto(10) do |i|
      pick = board.range_to_pick(i)
      if i % 2 == 0
        expect(pick).to eq( (i / 2)..(i / 2 + 1))
      else
        expect(pick).to eq( (i / 2)..(i / 2 + 2) )
      end
    end
  end
end