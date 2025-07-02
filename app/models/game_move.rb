class GameMove < ApplicationRecord
  belongs_to :game_board_tile, optional: true, dependent: :destroy
  belongs_to :game, optional: true
  belongs_to :card, optional: true
  belongs_to :user, optional: true

  validates :game_board_tile_id, presence: true
  validates :game_id, presence: true
  validates :card_id, presence: true
  validates :user_id, presence: true

  # Additional validations can be added here as needed
end