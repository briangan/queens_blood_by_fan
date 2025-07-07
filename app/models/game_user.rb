class GameUser < ApplicationRecord
  self.table_name = 'games_users'

  belongs_to :game, optional: true, dependent: :destroy
  belongs_to :user, optional: true

  validates_uniqueness_of :move_order, scope: :game_id, allow_nil: true

  before_save :set_move_order, if: -> { move_order.nil? }

  ##
  # Sets the move order for the user in the game.
  # The move order is set to the next available number.
  def set_move_order
    max_order = game.game_users.maximum(:move_order) || 0
    self.move_order = max_order + 1
  end

end