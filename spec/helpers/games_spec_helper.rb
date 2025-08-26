module GamesSpecHelper
  ##
  # Create a game, check board and create players.
  def prepare_game(game_factory, cols = 5, rows = 3)
    puts "Preparing game with #{cols} columns and #{rows} rows"
    board = Board.create_board(cols, rows)
    board_tiles = board.board_tiles # board.assign_claims_of_default_left_and_right_tiles!
    expect(board.board_tiles.count).to eq(board_tiles.size)
    expect(board.board_tiles.where(claiming_user_number: 1).count).to eq(board_tiles.size / 2)
    expect(board.board_tiles.where(claiming_user_number: 2).count).to eq(board_tiles.size / 2)

    if User.count < 2
      find_or_create(:user_1, :username){|u| u.password = 'test1234' }
      find_or_create(:user_2, :username){|u| u.password = 'test1234' }
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

  ##
  # Start a game with left and right claims for both players.
  # Initial 2 moves have their validations.
  # Use @prepare_game within.
  def start_game_with_left_and_right_claims(essential_card_numbers = [])
    game = prepare_game(:game, 3, 3)
    game.go_to_next_turn! 
    game.reload
    expect(game.game_moves.count).to eq 0
    essential_card_numbers += %w(1 8)
    essential_card_numbers.uniq!
    prepare_cards_and_decks_for_user(game.player_1, essential_card_numbers)
    prepare_cards_and_decks_for_user(game.player_2, essential_card_numbers)

    first_player_tile = game.find_tile(1, 2)
    expect(first_player_tile).not_to eq(nil), "Tile (1, 2) should be present in the game board tiles."
    expect(first_player_tile.claiming_user_id).to eq(game.player_1.id)
    expect(game.current_turn_player_number).to eq(1)

    first_trooper_card = Card.where(card_number: '1').first
    expect(first_trooper_card).not_to eq(nil)
    first_player_card = game.current_turn_user.cards.where(id: first_trooper_card.id).first
    expect(first_player_card).not_to eq(nil), "Player id #{game.current_turn_user_id} should have card no #{first_trooper_card.card_number} (#{first_trooper_card.name})"
    first_player_user_id = game.current_turn_user_id
    puts "| 4.1 | Player #{game.current_turn_user.username} (#{first_player_user_id}) has card #{first_player_card.id} (#{first_player_card.name})"

    game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
      game_board_tile_id: first_player_tile.id, card_id: first_player_card.id)
    expect(game_move.valid?).to be_truthy, "Game move should be valid. Errors: #{game_move.errors.full_messages.join(', ')}"
    puts "| 4.2 | Game move"

    game.proceed_with_game_move(game_move, dry_run: false)

    # Check that the tile is claimed.
    first_player_tile.reload
    expect(first_player_tile.current_card_id).to eq first_player_card.id
    expect(first_player_tile.claiming_user_id).to eq first_player_user_id
    puts "| 4.3 | Game move applied: #{game_move.errors.full_messages.join(', ')}"
    puts game.board_ascii_s
    
    # Check card's tiles claiming other tiles.
    [[1,1], [1,3], [2,2]].each do |position|
      specific_t = game.find_tile(position[0], position[1])
      expect(specific_t).not_to eq(nil), "Tile (#{position}) should be present in the game board tiles."
      expect(specific_t.claiming_user_id).to eq(first_player_user_id), "Tile (#{position}) should be claimed by player #{first_player_user_id}."
      expect(specific_t.current_card_id).to be_nil, "Tile (#{position}) should not have card yet."
    end

    # Second player
    second_player_card = game.player_2.cards.where(card_number: '8').first
    second_player_tile = game.find_tile(3, 2)
    second_player_move = GameMove.new(game_id: game.id, user_id: game.player_2.id, 
      game_board_tile_id: second_player_tile.id, card_id: second_player_card.id)
    expect(second_player_move.valid?).to be_truthy, "Second player move should be valid. Errors: #{second_player_move.errors.full_messages.join(', ')}"
    puts "| 4.4 | Second player move valid"

    game.proceed_with_game_move(second_player_move, dry_run: false)
    second_player_tile.reload
    expect(second_player_tile.current_card_id).to eq second_player_card.id
    expect(second_player_tile.claiming_user_id).to eq game.player_2.id
    puts "| 4.5 | Second player move applied"

    [[3,1], [2,2]].each do |position|
      specific_t = game.find_tile(position[0], position[1])
      expect(specific_t.claiming_user_id).to eq(game.player_2.id), "Tile (#{position}) should be claimed by player 2."
      expect(specific_t.current_card_id).to be_nil, "Tile (#{position}) should not have card yet."
    end
    puts "| 4.6 | Second player tiles claimed"

    middle_tile = game.find_tile(2, 2)
    expect(middle_tile.claiming_user_id).to eq(game.player_2.id), "Middle tile (2, 2) should be claimed by player second player."
    puts "| 4.7 | Middle tile (2, 2) claimed by player 2."

    game
  end
end