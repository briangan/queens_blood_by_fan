module CardAbilitiessSpecHelper
  def expect_correct_card_ability_effects_on_tile(card, target_tile)
    total_value_change = 0
    card.card_abilities.each do |ca|
      game_board_tile_ability = target_tile.game_board_tiles_abilities.where(card_ability_id: ca.id).first
      expect(game_board_tile_ability).not_to be_nil, "GameBoardTileAbility for #{ca.type}"
      
      action_value_sign = ca.type == 'EnfeebleAbility' ? -1 : 1
      expected_evaluated_value = action_value_sign * ca.action_value_evaluated(target_tile)
      expect(game_board_tile_ability.power_value_change).to eq(expected_evaluated_value), "Power value change for #{ca.type} should be #{expected_evaluated_value}"

      if ca.is_a?(EnhanceAbility)
        expect(target_tile.enhanced?).to be(true), "Tile for #{ca.type} should have enfeebled? true"
      elsif ca.is_a?(EnfeebleAbility)
        expect(target_tile.enfeebled?).to be(true), "Tile for #{ca.type} should have enfeebled? true"
      end
      total_value_change += game_board_tile_ability.power_value_change
    end

    expect(target_tile.power_value).to eq(target_tile.current_card.power + total_value_change), "Tile power value should be recalculated correctly"
  end
end