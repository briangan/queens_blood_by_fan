class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable
         # :recoverable, :rememberable, :
         # 
  has_many :game_users, dependent: :destroy
  has_many :decks, dependent: :destroy
  has_many :user_cards, class_name:'UserCard', dependent: :destroy
  has_many :cards, through: :user_cards

  validates_length_of :email, minimum: 5, maximum: 100
  validates_uniqueness_of :email, case_sensitive: false

  validates_length_of :username, minimum: 3, maximum: 60
  validates_uniqueness_of :username, case_sensitive: false

  after_create :random_pick_cards

  ## 
  # Creates at least Deck::MAX_CARDS_PER_DECK entries of UserCard referencing random selection cards.
  # @essential_card_ids [Array] Optional array of card IDs that must be included in the selection.
  def random_pick_cards(essential_card_ids = [], &block)
    if essential_card_ids.present?
      essential_card_ids.each do |card_id|
        user_cards.find_or_create_by(card_id: card_id)
      end
    end
    current_card_ids = user_cards.all.collect(&:card_id).uniq
    how_many_more = Deck::MAX_CARDS_PER_DECK + 5 + rand(10) - current_card_ids.size
    Card.where.not(id: current_card_ids).limit(how_many_more).order('RANDOM()').each do |card|
      UserCard.create(user_id: id, card_id: card.id)
      yield card if block_given?
    end
  end
end
