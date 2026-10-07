class DeckCard < ApplicationRecord
  self.table_name = 'decks_cards'
  belongs_to :deck
  belongs_to :card

  validates :deck_id, presence: true
  validates :card_id, presence: true

  # Additional validations can be added here if needed
end