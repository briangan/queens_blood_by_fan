module CardAbilitiessSpecHelper
  def expect_correct_card_ability_effects_on_tile(card, target_tile)
    card.card_abilities.each do |ca|
      game_board_tile_ability = target_tile.game_board_tiles_abilities.where(card_ability_id: ca.id).first
      expect(game_board_tile_ability).not_to be_nil, "GameBoardTileAbility for #{ca.type}"
      
      action_value_sign = ca.type == 'EnfeebleAbility' ? -1 : 1
      expected_evaluated_value = action_value_sign * ca.action_value_evaluated(target_tile)

      if ca.is_a?(EnhanceAbility)
        expect(game_board_tile_ability.power_value_change).to eq(expected_evaluated_value), "Power value change for #{ca.type} should be #{expected_evaluated_value}"
        expect(target_tile.enhanced?).to be(true), "Tile for #{ca.type} should have enfeebled? true"
  
      elsif ca.is_a?(EnfeebleAbility)
        expect(game_board_tile_ability.power_value_change).to eq(expected_evaluated_value), "Power value change for #{ca.type} should be #{expected_evaluated_value}"
        expect(target_tile.enfeebled?).to be(true), "Tile for #{ca.type} should have enfeebled? true"

      elsif ca.is_a?(RaiseRankAbility)
        expect(game_board_tile_ability.pawn_value_change).to eq(expected_evaluated_value), "Pawn value change for #{ca.type} should be #{expected_evaluated_value}"
        expect(target_tile.raised?).to be(true), "Tile for #{ca.type} should have raised? true"
      end
    end
    total_value_change = target_tile.game_board_tiles_abilities.collect(&:power_value_change).sum
    
    if (target_tile.enfeebled? && target_tile.game_board_tiles_abilities.count > 0) && (target_tile.power_value == 0)
      expect(target_tile.current_card_id).to be_nil, "Tile should not have a current card if power value is 0"
    elsif (target_tile.enhanced?)
      expect(target_tile.power_value).to eq(target_tile.current_card&.power + total_value_change), "Tile power value should be recalculated correctly"
    end
  end
end