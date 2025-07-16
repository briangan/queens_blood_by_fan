class UserCard < ApplicationRecord
  self.table_name = 'users_cards'
  
  # Associations
  belongs_to :user
  belongs_to :card

  validates :user_id, presence: true
  validates :card_id, presence: true

  # Additional validations can be added here if needed
end