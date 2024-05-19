require 'rails_helper'

RSpec.describe Game, type: :feature do

  it 'should have a board' do
    game = prepare_game(:game, 5, 3)
    game.pick_pawns_for_players!
    check_pawn_rank_and_claiming_user_id(game.users, game.board)
  end

  private 

  def prepare_game(game_factory, cols = 5, rows = 3)
    board = Board.create_board(cols, rows)
    expect(board.board_tiles.count).to eq(cols * rows)

    game = Game.new(board_id: board.id)
    expect(game).to be_valid
    game.save
    expect(game.board_id).to eq board.id

    game.game_users.find_or_create_by(user_id: find_or_create(:user_1, :username).id )
    game.game_users.find_or_create_by(user_id: find_or_create(:user_2, :username).id )
    expect(game.users.size).to eq(2)

    game
  end

  def check_pawn_rank_and_claiming_user_id(players, board)
    player1 = players.first
    player2 = players[1]
    pick = board.range_to_pick(board.rows)
    board.board_tiles.each do |tile|
      if tile.column == 1 && pick.include?(tile.row)
        expect(tile.claiming_user_id).to eq(player1.id)
      elsif tile.column == 5 && pick.include?(tile.row)
        expect(tile.claiming_user_id).to eq(player2.id)
      end
    end

    check_range_to_pick(board)
  end

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