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

  ##############################
  # Class Methods
  
  def self.populate_decks_for_user(user)
    (Deck.where(user_id: user.id).count + 1).upto(MAX_DECKS_PER_USER) do |i|
      Deck.create(user_id: user.id, name: "Deck #{i}")
    end
  end

  def self.populate_cards_for_user(user)
    current_card_ids = UserCard.where(user_id: user.id).pluck(:card_id).uniq
    how_many_more = MAX_CARDS_PER_DECK + 5 + rand(10) - current_card_ids.size 
    Card.where.not(id: current_card_ids).limit(how_many_more).order('RANDOM()').each do |card|
      UserCard.create(user_id: user.id, card_id: card.id)
    end
  end

end