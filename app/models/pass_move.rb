class PassMove < GameMove
  validate :check_user_turn_and_tile

  def check_user_turn_and_tile
    if self.card_id.present?
      errors.add(:card_id, I18n.t('game.game_moves.errors.pass_move_cannot_have_card'))
    end

    if self.game_board_tile_id.present?
      errors.add(:game_board_tile_id, I18n.t('game.game_moves.errors.pass_move_cannot_have_tile'))
    end

    if self.user_id != self.game.current_turn_user_id
      errors.add(:user_id, I18n.t('game.game_moves.errors.not_your_turn'))
    end
  end
end