module CardAbilitiessSpecHelper
  def expect_correct_card_ability_effects_on_tile(card, target_tile)
    if ( target_tile.current_card_id.nil? || target_tile.current_card.nil? )
      expect(target_tile.affected_tiles_to_abilities.where("pawn_value_change IS NULL OR pawn_value_change = 0").count).to eq(0), "Tile has no current card, so should not have any GameBoardTileAbilities"
      return
    end
    card.card_abilities.each do |ca|
      game_board_tile_ability = target_tile.affected_tiles_to_abilities.where(card_ability_id: ca.id).first
      expect(game_board_tile_ability).not_to be_nil, "AffectedTileToAbility for #{ca.type}"
      
      expected_evaluated_value = ca.action_value_evaluated(target_tile)

      if ca.is_a?(EnhanceAbility)
        expect(game_board_tile_ability.power_value_change).to eq(expected_evaluated_value), "Power value change for #{ca.type} should be #{expected_evaluated_value}"
        expect(target_tile.enhanced?).to be(true), "Tile for #{ca.type} should have enhanced? true"

      elsif ca.is_a?(EnfeebleAbility)
        expect(game_board_tile_ability.power_value_change).to eq(expected_evaluated_value), "Power value change for #{ca.type} should be #{expected_evaluated_value}"
        expect(target_tile.enfeebled?).to be(true), "Tile for #{ca.type} should have enfeebled? true"

      elsif ca.is_a?(RaiseRankAbility)
        expect(game_board_tile_ability.pawn_value_change).to eq(expected_evaluated_value), "Pawn value change for #{ca.type} should be #{expected_evaluated_value}"
        expect(target_tile.raised?).to be(true), "Tile for #{ca.type} should have raised? true"
      end
    end
    total_value_change = target_tile.affected_tiles_to_abilities.collect(&:power_value_change).sum
    
    if (target_tile.enfeebled? && target_tile.affected_tiles_to_abilities.count > 0) && (target_tile.power_value == 0)
      expect(target_tile.current_card_id).to be_nil, "Tile should not have a current card if power value is 0"
    elsif (target_tile.enhanced?)
      expect(target_tile.power_value).to eq(target_tile.current_card&.power + total_value_change), "Tile power value should be recalculated correctly"
    end
  end
end