##
# Attribute :move_order is they factor to determine whether already applied to game. 
class GameMove < ApplicationRecord
  belongs_to :game_board_tile, optional: true, dependent: :destroy
  belongs_to :game, optional: true
  belongs_to :card, optional: true
  belongs_to :user, optional: true

  validates :game_board_tile_id, presence: true, unless: -> { self.is_a?(PassMove) }
  validates :game_id, presence: true
  validates :card_id, presence: true, unless: -> { self.is_a?(PassMove) }
  validates :user_id, presence: true

  validate :check_user_turn_and_tile

  # after_create :apply_game_move # leave to separate call to game.proceed_with_game_move

  # Additional validations can be added here as needed
  
  def check_user_turn_and_tile
    if game.current_turn_user_id != user_id
      errors.add(:user_id, I18n.t('game.game_moves.errors.not_your_turn'))
      return false
    end
    self.game_board_tile ||= GameBoardTile.find_by(id: game_board_tile_id)
    if self.game_board_tile.nil?
      errors.add(:game_board_tile_id, I18n.t('game.game_moves.errors.tile_not_claimed'))
      return false
    end
    self.card ||= Card.find_by(id: card_id)
    if self.card.nil?
      errors.add(:card_id, I18n.t('game.game_moves.errors.card_not_in_hand'))
      return false
    end
    if game_board_tile.claiming_user_id
      if game_board_tile.claiming_user_id != user_id
        errors.add(:game_board_tile_id, I18n.t('game.game_moves.errors.cannot_play_on_opponents_tile'))
        return false
      elsif game_board_tile.current_card_id && !self.card.can_replace_card_on_tile?
        errors.add(:card_id, I18n.t('game.game_moves.errors.card_cannot_replace'))
        return false
      end
    end
    if card.pawn_rank && card.pawn_rank > game_board_tile.pawn_value
      errors.add(:card_id, I18n.t('game.game_moves.errors.card_pawn_rank_higher_than_tile'))
      return false
    end
    true
  end

  # This method is called ONLY after the game move is created.
  # def apply_game_move
  #   return false unless move_order.nil?

  #   # Proceed with the move.
  #   game.proceed_with_game_move(self)

  #   true
  # end
end