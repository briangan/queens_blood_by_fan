class Deck < ApplicationRecord

  MAX_DECKS_PER_USER = 5
  MAX_CARDS_PER_DECK = 15

  belongs_to :user, optional: true, dependent: :destroy
  has_many :deck_cards, dependent: :destroy
  has_many :cards, through: :deck_cards

  validates_presence_of :user_id

  before_save :set_default_name

  ##
  # Sets a default name for the deck if none is provided.
  def set_default_name
    self.name = "Deck #{Time.now.to_i}" if name.blank?
  end

  ##
  # Returns the cards in the deck ordered by their position.
  def ordered_cards
    deck_cards.order(:position).map(&:card)
  end

end