##
# Data of a board spot which can be empty or placed with a card.
class GameBoardTile < ApplicationRecord
  has_paper_trail on: [:update]

  belongs_to :game, dependent: :destroy, optional: true
  belongs_to :board, optional: true
  
  belongs_to :current_card, class_name:'Card', optional: true
  belongs_to :claiming_user, class_name: 'User', foreign_key: 'claming_user_id', optional: true

  has_many :game_moves

  scope :claimed, -> { where.not(claming_user_id: nil) }

  validates_absence_of :game_id, :board_id, :column, :row
end