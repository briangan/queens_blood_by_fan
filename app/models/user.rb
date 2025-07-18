class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable
         # :recoverable, :rememberable, :validatable
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
  def random_pick_cards(&block)
    current_card_ids = user_cards.all.collect(&:card_id).uniq
    how_many_more = Deck::MAX_CARDS_PER_DECK + 5 + rand(10) - current_card_ids.size
    Card.where.not(id: current_card_ids).limit(how_many_more).order('RANDOM()').each do |card|
      UserCard.create(user_id: id, card_id: card.id)
      yield card if block_given?
    end
  end
end
