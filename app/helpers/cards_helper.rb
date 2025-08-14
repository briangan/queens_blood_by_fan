module CardsHelper
  # @which_player [Integer] 1 or 2, to flip the x coordinate for player 2. Default 1.
  # Returns the data attributes for a card wrapper/tag.
  def card_data_attr(card, which_player = 1)
    { card_id: card.id, pawn_tiles: card.pawn_tiles_data(which_player), affected_tiles: card.affected_tiles_data(which_player), ability_effects: card.ability_effects_data, pawn_rank: card.pawn_rank, power: card.power }
  end

  def custom_power_icon(game_board_tile)
    content_tag :span, class: "custom-power-icon#{' enhanced-glowing-border' if game_board_tile.enhanced?}#{' enfeebled-glowing-border' if game_board_tile.enfeebled?}" do
      game_board_tile.power_value.to_s
    end
  end

  def preview_effect_label_css_class(power_value_total_change)
    return 'preview-effect-label' if power_value_total_change.nil? || power_value_total_change == 0
    "preview-effect-label power#{power_value_total_change < 0 ? 'down' : 'up'}-effect"
  end

  def preview_effect_label(game_board_tile)
    t = game_board_tile.power_value_total_change
    content_tag :h3, class: preview_effect_label_css_class(t) do
      t > 0 ? "+#{t}" : t.to_s
    end
  end
end