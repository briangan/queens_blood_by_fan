##
# Data of a board spot which can be empty or placed with a card.
class GameBoardTile < ApplicationRecord
  MAX_PAWN_VALUE = 3
  
  has_paper_trail on: [:update]

  belongs_to :game, dependent: :destroy, optional: true
  belongs_to :board, optional: true
  
  belongs_to :current_card, class_name:'Card', optional: true
  belongs_to :claiming_user, class_name: 'User', foreign_key: 'claming_user_id', optional: true

  has_many :game_moves

  # Based on some other card(s)'s card abilities affecting this tile.
  attr_accessor :effective_card_abilities # <Array of CardAbility>

  scope :claimed, -> { where('claming_user_id IS NOT nil') }

  validates_presence_of :game_id, :board_id, :column, :row

  before_save :normalize_attributes

  def cell_data_attr
    { 
      'tile-position' => "#{column},#{row}", 'game-board-tile-id' => "#{id}", 
      'claiming-user-id' => "#{claiming_user_id}", 'pawn-value' => "#{pawn_value}"
    }
  end 

  private

  def normalize_attributes
    self.pawn_value = 1 if claiming_user_id && pawn_value.to_i < 1
  end
end