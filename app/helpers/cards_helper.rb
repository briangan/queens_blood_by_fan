module CardsHelper
  # Returns the data attributes for a card wrapper/tag.
  def card_data_attr(card)
    { pawn_tiles: card.pawn_tiles_data, pawn_rank: card.pawn_rank, power: card.power }
  end
end