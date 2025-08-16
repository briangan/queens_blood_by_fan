require 'rails_helper'
require 'helpers/cards_spec_helper'
require 'helpers/card_abilities_spec_helper'

include CardsSpecHelper
include CardAbilitiessSpecHelper

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

      the_following_user_id = game.current_turn_user_id == game.player_1.id ? game.player_2.id : game.player_1.id

      expect(game.game_users.where(user_id: game.current_turn_user_id).first&.move_order).to eq 1
      expect(game.game_users.where(user_id: the_following_user_id).first&.move_order).to be > 1

      prepare_cards_and_decks_for_user(game.player_1 )
      prepare_cards_and_decks_for_user(game.player_2 )

      # Falty game moves
      valid_game_board_tile = game.game_board_tiles.where(claiming_user_id: game.current_turn_user_id).first
      first_player_card = game.current_turn_user.cards.where(pawn_rank: valid_game_board_tile.pawn_value).first

      game_move = GameMove.new(game_id: game.id, user_id: the_following_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.1 | Game move is first_tile"

      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: 0, card_id: first_player_card.id)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.2 | Game move is first_tile"

      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: 0)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.3 | Game move is invalid"

      other_valid_game_board_tile = game.game_board_tiles.where(claiming_user_id: the_following_user_id).first
      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: other_valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.4 | Game move is invalid"

      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be_truthy, "Game move should be valid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.5 | Game move valid"

      valid_game_board_tile.update_columns(current_card_id: first_player_card.id, claiming_user_id: game.current_turn_user_id)
      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.6 | Game move invalid"

      first_replacement_card = game.current_turn_user.cards.where(type: 'ReplacementCard').first
      if first_replacement_card.nil?
        first_replacement_card = ReplacementCard.first
        game.current_turn_user.user_cards.create(card_id: first_replacement_card.id)
      end
      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_replacement_card.id)
      expect(game_move.valid?).to be_truthy, "Game move should be valid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.7 | Game move w/ replacement card valid"
    end

    it 'Should Have Working Enhance and Enfeeble Cards/Moves' do
      game = start_game_with_left_and_right_claims(%w(1 8 13 26))
      
      first_player_tile = game.game_moves.first.game_board_tile
      second_player_tile = game.game_moves[1].game_board_tile

      enhance_card = Card.where(card_number: '13').first
      expect(enhance_card).not_to be_nil, "Enhance card should be present"
      first_player_below_tile = game.find_tile(first_player_tile.column, first_player_tile.row + 1)
      first_player_enhancement_move = GameMove.new(game_id: game.id, user_id: game.player_1.id, 
        game_board_tile_id: first_player_below_tile.id, card_id: enhance_card.id)
      expect(first_player_enhancement_move.valid?).to be_truthy, "First player enhancement move should be valid. Errors: #{first_player_enhancement_move.errors.full_messages.join(', ')}"
      puts "| 4.8 | First player enhancement move valid"

      game.proceed_with_game_move(first_player_enhancement_move, dry_run: false)
      first_player_below_tile.reload
      expect(first_player_below_tile.current_card_id).to eq enhance_card.id
      
      first_player_tile.reload
      expect(first_player_tile.affected_tiles_to_abilities.collect(&:card_ability_id).sort).to eq(enhance_card.card_abilities.collect(&:id).sort)
      expect_correct_card_ability_effects_on_tile(enhance_card, first_player_tile)
      puts "| 4.9 | First player enhancement move applied"

      enfeeble_card = Card.where(card_number: '26').first
      second_tile_below = game.find_tile(second_player_tile.column, second_player_tile.row + 1)
      second_player_enfeeble_move = GameMove.new(game_id: game.id, user_id: game.player_2.id, 
        game_board_tile_id: second_tile_below.id, card_id: enfeeble_card.id)
      expect(second_player_enfeeble_move.valid?).to be_truthy, "Second player enfeeble move should be valid. Errors: #{second_player_enfeeble_move.errors.full_messages.join(',')}"
      puts "| 4.10 | Second player enfeeble move valid"

      game.proceed_with_game_move(second_player_enfeeble_move, dry_run: false)

      second_tile_below.reload
      expect(second_tile_below.current_card_id).to eq(enfeeble_card.id)
      expect(second_tile_below.claiming_user_id).to eq(game.player_2.id)
      puts "| 4.11 | Second player enfeeble claimed the tile"

      second_player_tile.reload
      expect(second_player_tile.affected_tiles_to_abilities.collect(&:card_ability_id).sort).to eq(enfeeble_card.card_abilities.collect(&:id).sort)
      expect_correct_card_ability_effects_on_tile(enfeeble_card, second_player_tile)
      puts "| 4.12 | Second player enfeeble move applied"
      puts game.board_ascii_s

      # First player enfeeble move
      first_corner_tile = game.find_tile(1, 1)
      first_player_enfeeble_move = GameMove.new(game_id: game.id, user_id: game.player_1.id, 
        game_board_tile_id: first_corner_tile.id, card_id: enfeeble_card.id)
      expect(first_player_enfeeble_move.valid?).to be_truthy, "First player enfeeble move should be valid. Errors: #{first_player_enfeeble_move.errors.full_messages.join(', ')}"
      puts "| 4.13 | First player enfeeble move valid"

      game.proceed_with_game_move(first_player_enfeeble_move, dry_run: false)
      first_player_tile.reload
      expect_correct_card_ability_effects_on_tile(enfeeble_card, first_player_tile)
      puts "| 4.14 | First player enfeeble move applied"

      second_corner_tile = game.find_tile(3, 1)
      second_player_enfeeble_move = GameMove.new(game_id: game.id, user_id: game.player_2.id, 
        game_board_tile_id: second_corner_tile.id, card_id: enfeeble_card.id)
      expect(second_player_enfeeble_move.valid?).to be_truthy, "Second player enfeeble move should be valid. Errors: #{second_player_enfeeble_move.errors.full_messages.join(', ')}"
      puts "| 4.15 | Second player enfeeble move valid"

      game.proceed_with_game_move(second_player_enfeeble_move, dry_run: false)
      second_player_tile.reload
      puts game.board_ascii_s

      expect_correct_card_ability_effects_on_tile(enfeeble_card, second_player_tile)
      puts "| 4.16 | Second player enfeeble move applied"
    end


    it 'Should Have Working RaiseRank Ability in Card' do
      game = start_game_with_left_and_right_claims(%w(1 8 71))
      
      first_player_tile = game.game_moves.first.game_board_tile
      second_player_tile = game.game_moves[1].game_board_tile

      raise_rank_card = Card.where(card_number: '71').first
      expect(raise_rank_card).not_to be_nil, "RaiseRank card should be present"

      first_player_above_tile = game.find_tile(first_player_tile.column, first_player_tile.row - 1)
      original_pawn_value = first_player_above_tile.pawn_value
      first_player_below_tile = game.find_tile(first_player_tile.column, first_player_tile.row + 1)
      first_player_raise_rank = GameMove.new(game_id: game.id, user_id: game.player_1.id, 
        game_board_tile_id: first_player_below_tile.id, card_id: raise_rank_card.id)
      expect(first_player_raise_rank.valid?).to be_truthy, "First player raise rank move should be valid. Errors: #{first_player_raise_rank.errors.full_messages.join(', ')}"
      puts "| 5.8 | First player raise rank move valid"

      game.proceed_with_game_move(first_player_raise_rank, dry_run: false)
      first_player_below_tile.reload
      expect(first_player_below_tile.current_card_id).to eq raise_rank_card.id
      
      expect(first_player_above_tile.affected_tiles_to_abilities.collect(&:card_ability_id).sort).to eq(raise_rank_card.card_abilities.collect(&:id).sort)
      expected_pawn_value = original_pawn_value + raise_rank_card.card_abilities.collect{|ca| ca.action_value_evaluated(first_player_above_tile)}.sum
      expected_pawn_value = [GameBoardTile::MAX_PAWN_VALUE, expected_pawn_value].min
      expect(first_player_above_tile.pawn_value).to eq(expected_pawn_value), "Tile pawn_value should be raised to #{expected_pawn_value}"

      expect_correct_card_ability_effects_on_tile(raise_rank_card, first_player_above_tile)
      puts "| 5.9 | First player enhancement move applied"

    end

    it 'Should Have After CardEvent Ability in Affected Card' do
      game = start_game_with_left_and_right_claims(%w(1 8 3 36))
      
      first_player_tile = game.game_moves.first.game_board_tile
      second_player_tile = game.game_moves[1].game_board_tile
      after_destroy_card = Card.where(card_number: '36').first
      expect(after_destroy_card).not_to be_nil, "AfterDestroy card should be present"

      # Card w/ after_destroy ability should not have effect when 1st played
      first_player_tile_below = game.find_tile(first_player_tile.column, first_player_tile.row + 1)
      expect(first_player_tile_below).not_to be_nil, "First player tile below should be present"

      first_player_tile_original_power = first_player_tile.power_value
      after_destroy_card_move = GameMove.new(game_id: game.id, user_id: game.player_1.id,
        game_board_tile_id: first_player_tile_below.id, card_id: after_destroy_card.id)
      expect(after_destroy_card_move.valid?).to be_truthy, "AfterDestroy card move should be valid. Errors: #{after_destroy_card_move.errors.full_messages.join(', ')}"
      puts "| 6.8 | AfterDestroy card move valid"

      game.proceed_with_game_move(after_destroy_card_move, dry_run: false)
      first_player_tile.reload
      first_player_tile_below.reload
      game.reload
      expect(first_player_tile.power_value).to eq(first_player_tile_original_power), "First player tile initially should not be affected by AfterDestroy card"
      puts "| 6.9 | AfterDestroy card placed"

      puts game.board_ascii_s

      expect(first_player_tile_below.claiming_player_number).to eq(1)
      expect(first_player_tile_below.current_card_id).to eq(after_destroy_card.id)

      second_player_tile_below = game.find_tile(second_player_tile.column, second_player_tile.row + 1)
      expect(second_player_tile_below).not_to be_nil, "Second player tile below should be present"
      second_player_tile_below.update(pawn_value: 2) # for quick use of enfeeble card

      grenadier_card = Card.find_by(card_number: '3') # shoots an enfeeble effect only at x2 away
      expect(grenadier_card).not_to be_nil, "Grenadier card should be present"
      second_player_enfeeble_move = GameMove.new(game_id: game.id, user_id: game.player_2.id,
        game_board_tile_id: second_player_tile_below.id, card_id: grenadier_card.id)
      expect(second_player_enfeeble_move.valid?).to be_truthy, "Second player enfeeble move should be valid. Errors: #{second_player_enfeeble_move.errors.full_messages.join(', ')}"
      puts "| 6.10 | Second player enfeeble move valid"

      expected_first_player_tile_power = first_player_tile.power_value + after_destroy_card.card_abilities.first.action_value_evaluated(first_player_tile)

      game.proceed_with_game_move(second_player_enfeeble_move, dry_run: false)
      second_player_tile_below.reload
      expect(second_player_tile_below.current_card_id).to eq(grenadier_card.id)
      puts "| 6.11 | Grenadier card placed"

      game.reload
      first_player_tile.reload
      puts game.board_ascii_s

      bombed_tile = game.find_tile(second_player_tile_below.column - 2, second_player_tile_below.row)

      expect(bombed_tile.current_card_id).to be_nil, "Bombed tile should be destroyed"
      puts "| 6.12 | Bombed tile destroyed"

      expect_correct_card_ability_effects_on_tile(after_destroy_card, first_player_tile)
      expect(first_player_tile.power_value).to eq(expected_first_player_tile_power), "First player tile power expected #{expected_first_player_tile_power} b/c after_destroy effect"

    end


    it 'Should Have Working Spawn Ability in Card' do
      game = start_game_with_left_and_right_claims(%w(1 8 96))
      
      first_player_tile = game.game_moves.first.game_board_tile
      second_player_tile = game.game_moves[1].game_board_tile

      spawn_card = Card.where(card_number: '96').first
      expect(spawn_card).not_to be_nil, "Spawn card should be present"
      expect(spawn_card.children_cards.count).to be >=(1), "Spawn card should have child card(s)"

      # just to make sure CardAbiltity correct
      ca = spawn_card.card_abilities.find_or_create_by(type: "SpawnAbility") do|_ca|
        _ca.assign_attributes("when"=>"played", "action_type"=>"spawn")
      end
      ca.which = "empty_positions"
      ca.action_value = "target_tile.pawn_value*2"
      ca.save

      first_player_above_tile = game.find_tile(first_player_tile.column, first_player_tile.row - 1)
      first_player_below_tile = game.find_tile(first_player_tile.column, first_player_tile.row + 1)
      first_player_spawn = GameMove.new(game_id: game.id, user_id: game.player_1.id,
        game_board_tile_id: first_player_below_tile.id, card_id: spawn_card.id)
      expect(first_player_spawn.valid?).to be_truthy, "First player spawn move should be valid. Errors: #{first_player_spawn.errors.full_messages.join(', ')}"
      puts "| 7.8 | First player spawn move valid"

      game.proceed_with_game_move(first_player_spawn, dry_run: false)
      first_player_below_tile.reload
      first_player_above_tile.reload
      first_player_above_tile.affected_tiles_to_abilities.reload
      game.reload
      expect(first_player_below_tile.current_card_id).to eq spawn_card.id
      puts "| 7.9 | Spawn card placed"

      puts game.board_ascii_s

      expect(first_player_above_tile.current_card_id).to eq(spawn_card.children_cards.first.id)
      expected_spawned_tile_power = ca.action_value_evaluated(first_player_above_tile)
      expect(first_player_above_tile.power_value).to eq( expected_spawned_tile_power )
      expect(first_player_above_tile.affected_tiles_to_abilities.collect(&:card_ability_id).sort).to eq( [ca.id] )
    end
  end

  ################################################
  private 

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