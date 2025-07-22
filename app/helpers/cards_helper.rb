module CardsHelper
  # @which_player [Integer] 1 or 2, to flip the x coordinate for player 2. Default 1.
  # Returns the data attributes for a card wrapper/tag.
  def card_data_attr(card, which_player = 1)
    { card_id: card.id, pawn_tiles: card.pawn_tiles_data(which_player), affected_tiles: card.affected_tiles_data(which_player), ability_effects: card.ability_effects_data, pawn_rank: card.pawn_rank, power: card.power }
  end
end