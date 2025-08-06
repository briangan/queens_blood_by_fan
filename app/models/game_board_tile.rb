##
# Data of a board spot which can be empty or placed with a card.
class GameBoardTile < ApplicationRecord
  MAX_PAWN_VALUE = 3
  
  has_paper_trail on: [:update]

  belongs_to :game, dependent: :destroy, optional: true
  belongs_to :board, optional: true
  
  belongs_to :current_card, class_name:'Card', optional: true
  belongs_to :claiming_user, class_name: 'User', foreign_key: 'claming_user_id', optional: true

  has_many :game_board_tiles_abilities, class_name:'GameBoardTileAbility', dependent: :destroy
  
  # Based on some other card(s)'s card abilities affecting this tile.
  has_many :affecting_card_abilities, class_name: 'CardAbility', source: :card_ability, through: :game_board_tiles_abilities

  # Scopes
  scope :claimed, -> { where('claming_user_id IS NOT nil') }

  # Validations
  validates_presence_of :game_id, :board_id, :column, :row

  # before and after callbacks
  before_save :normalize_attributes

  ##
  # The HTML data attributes for this tile.
  def cell_data_attr
    { 
      'tile-position' => "#{column},#{row}", 'game-board-tile-id' => "#{id}", 
      'claiming-user-id' => "#{claiming_user_id}", 'pawn-value' => "#{pawn_value}"
    }
  end

  def power_value_total_change
    game_board_tiles_abilities.collect(&:power_value_change).compact.sum
  end

  # Current card + all card abilities affecting this tile.
  # Record not saved, just the attributes are set.
  def recalculate_power_value
    self.power_value = current_card&.power&.to_i + power_value_total_change
  end

  private

  def normalize_attributes
    self.pawn_value = 1 if claiming_user_id && pawn_value.to_i < 1
  end
end