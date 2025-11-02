require 'rails_helper'
require 'helpers/cards_spec_helper'
require 'helpers/card_abilities_spec_helper'
require 'helpers/games_spec_helper'

include CardsSpecHelper
include CardAbilitiesSpecHelper
include GamesSpecHelper

describe Game, type: :feature do

  before(:context) do
    ActiveRecord::Base.logger.level = :warn
    reload_cards
  end

  context 'When creating a game' do
    it 'Should have a board and board tiles and validate GameMove instances' do
      game = prepare_game(:game, 5, 3)
      game.go_to_next_turn! 
      game.reload
      expect(game.game_moves.count).to eq 0
      expect(game.game_users.collect(&:user_id).include?(game.current_turn_user_id)).to be true

      the_following_user_id = game.next_player_user_id

      puts "| 2.1 | Game move order"
      expect(game.game_users.where(user_id: game.current_turn_user_id).first&.move_order).to eq 1
      expect(game.game_users.where(user_id: the_following_user_id).first&.move_order).to be > 1

      prepare_cards_and_decks_for_user(game.player_1 )
      prepare_cards_and_decks_for_user(game.player_2 )

      # Faulty game moves
      puts "| 2.2 | Faulty game moves"
      valid_game_board_tile = game.game_board_tiles.where(claiming_user_id: game.current_turn_user_id).first
      first_player_card = game.current_turn_user.cards.where(pawn_rank: valid_game_board_tile.pawn_value).first

      game_move = GameMove.new(game_id: game.id, user_id: the_following_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.1 | Game move: current_turn_user_id mismatches the_following_user_id"

      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: 0, card_id: first_player_card.id)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.2 | Game move: invalid game_board_tile_id"

      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: 0)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.3 | Game move: invalid card_id"

      other_valid_game_board_tile = game.game_board_tiles.where(claiming_user_id: the_following_user_id).first
      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: other_valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.4 | Game move: the card used is not the_following_user_id's"

      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be_truthy, "Game move should be valid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.5 | Game move valid"

      valid_game_board_tile.update_columns(current_card_id: first_player_card.id, claiming_user_id: game.current_turn_user_id)
      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_player_card.id)
      expect(game_move.valid?).to be(false), "Game move should be invalid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.6 | Game move: tile already has a card placed"

      first_replacement_card = game.current_turn_user.cards.where(type: 'ReplacementCard').first
      if first_replacement_card.nil?
        first_replacement_card = ReplacementCard.first
        game.current_turn_user.user_cards.create(card_id: first_replacement_card.id)
      end
      game_move = GameMove.new(game_id: game.id, user_id: game.current_turn_user_id, 
        game_board_tile_id: valid_game_board_tile.id, card_id: first_replacement_card.id)
      expect(game_move.valid?).to be_truthy, "Game move should be valid. Errors: #{game_move.errors.full_messages.join(', ')}"
      puts "| 3.7 | Game move w/ replacement card valid"

      pass_move = PassMove.new(game_id: game.id, user_id: game.the_other_player_user_id(game.current_turn_user_id))
      expect(pass_move.valid?).to be(false), "Pass move should be invalid.  Wrong user_id. Errors: #{pass_move.errors.full_messages.join(', ')}"
      puts "| 3.8 | Pass move invalid user_id"

      pass_move.user_id = game.current_turn_user_id
      expect(pass_move.valid?).to be(true), "Pass move should be valid. Errors: #{pass_move.errors.full_messages.join(', ')}"
      puts "| 3.9 | Pass move valid"

      pass_move.card_id = first_player_card.id
      expect(pass_move.valid?).to be(false), "Pass move should be invalid. Has card_id. Errors: #{pass_move.errors.full_messages.join(', ')}"
      expect(pass_move.errors[:card_id].present?).to be(true), "Pass move should have card_id error"
      puts "| 3.10 | Pass move invalid has card_id"

      pass_move.card_id = nil
      pass_move.game_board_tile_id = valid_game_board_tile.id
      expect(pass_move.valid?).to be(false), "Pass move should be invalid. Has game_board_tile_id. Errors: #{pass_move.errors.full_messages.join(', ')}"
      expect(pass_move.errors[:game_board_tile_id].present?).to be(true), "Pass move should have game_board_tile_id error"
      puts "| 3.10 | Pass move invalid has game_board_tile_id"
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

      second_corner_tile = game.find_tile(-1, 1)
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


    it 'Should Have Working RaiseRank Ability in Card and Creates PassMove' do
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

      game.reload
      expect(game.current_turn_user_id).to eq(game.player_2.id), "It should be second player's turn"
      pass_move = PassMove.new(game_id: game.id, user_id: game.player_2.id)
      expect(pass_move.valid?).to be_truthy, "Pass move should be valid. Errors: #{pass_move.errors.full_messages.join(', ')}"
      puts "| 5.10 | Pass move valid"

      game.proceed_with_game_move(pass_move, dry_run: false)
      game.reload
      expect(game.current_turn_user_id).to eq(game.player_1.id), "It should go back to first player's turn"
      game.game_moves.reload
      last_move = game.game_moves.last
      expect(last_move).to be_a(PassMove), "Last game move should be a PassMove"
      expect(last_move.user_id).to eq(game.player_2.id), "Last game move should be by second player"
      puts "| 5.11 | Pass move applied"

      second_move = PassMove.new(game_id: game.id, user_id: game.player_1.id)
      game.proceed_with_game_move(second_move, dry_run: false)
      game.reload
      expect(game.status).to eq('COMPLETED'), "Game should be COMPLETED after two consecutive PassMoves"
      expect(game.winner_user_id).to eq(game.player_1.id), "First player should be the winner"
      puts "| 5.12 | Second pass move applied, game completed"

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

      second_player_tile_below = game.find_tile(3, 3)
      expect(second_player_tile_below).not_to be_nil, "Second player tile below should be present"
      second_player_tile_below.update(pawn_value: 2, claiming_user_id: game.player_2.id) # for quick use of enfeeble card

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
      game.reload
      first_player_tile.reload
      puts game.board_ascii_s

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

  

end