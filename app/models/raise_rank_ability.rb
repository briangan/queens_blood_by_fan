class RaiseRankAbility < CardAbility
  validate :check_action_value

  def apply_effect_to_tile(source_tile, target_tile, options = {})
    if action_value # && action_type == 'raise_rank'
      target_tile.pawn_value = target_tile.pawn_value_was.to_i + action_value_evaluated.to_i
      target_tile.claiming_user_id = source_tile.claiming_user_id if target_tile.current_card_id.nil?
    end
  end

  def check_action_value
    if action_value.to_i > 0
      true
    else
      self.errors.add(:action_value, 'must be a positive integer')
      false
    end
  end

  def normalize_data
    super()
    self.which = 'positions' if self.when.blank?
  end
end