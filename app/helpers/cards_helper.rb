module CardsHelper
  # Returns the data attributes for a card wrapper/tag.
  def card_data_attr(card)
    { card_id: card.id, pawn_tiles: card.pawn_tiles_data, affected_tiles: card.affected_tiles_data, ability_effects: card.ability_effects_data, pawn_rank: card.pawn_rank, power: card.power }
  end
end