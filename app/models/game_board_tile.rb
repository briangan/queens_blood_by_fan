##
# Data of a board spot which can be empty or placed with a card.
class GameBoardTile < ApplicationRecord
  has_paper_trail on: [:update]

  belongs_to :game, dependent: :destroy, optional: true
  belongs_to :board, optional: true
  
  belongs_to :current_card, class_name:'Card', optional: true
  belongs_to :claiming_user, class_name: 'User', foreign_key: 'claming_user_id', optional: true

  has_many :game_moves

  scope :claimed, -> { where('claming_user_id IS NOT nil') }

  validates_presence_of :game_id, :board_id, :column, :row

  before_save :normalize_attributes

  private

  def normalize_attributes
    self.pawn_value = 1 if claiming_user_id && pawn_value.to_i < 1
  end
end