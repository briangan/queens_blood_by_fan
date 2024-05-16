require 'rails_helper'

RSpec.describe Game, type: :feature do

  it 'should have a board' do
    game = prepare_game(:game)
  end

  private 

  def prepare_game(game_factory, cols = 5, rows = 3)
    board = Board.create_board(cols, rows)
    expect(board.board_tiles.count).to eq(cols * rows)

    game = Game.new(board_id: board.id)
    expect(game).to be_valid
    game.save

    game.game_users.find_or_create_by(user_id: find_or_create(:user_1, :username).id )
    game.game_users.find_or_create_by(user_id: find_or_create(:user_2, :username).id )
    expect(game.users.size).to eq(2)

    game
  end
end