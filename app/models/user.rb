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
end
