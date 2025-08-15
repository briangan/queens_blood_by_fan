class RaiseRankAbility < CardAbility
  validate :check_action_value

  def apply_effect_to_tile(source_tile, target_tile, options = {})
    list = [] # super(source_tile, target_tile, options) # not newly claiming but should be already claimed
    if action_value # && action_type == 'raise_rank'
      pawn_value_change = action_value_evaluated(target_tile).to_i
      target_tile.pawn_value = [target_tile.pawn_value_was.to_i + pawn_value_change, GameBoardTile::MAX_PAWN_VALUE].min
      target_tile.claiming_user_id = source_tile.claiming_user_id if target_tile.current_card_id.nil?
      a = target_tile.affected_tiles_to_abilities.new(source_game_board_tile_id: source_tile.id,
              card_ability_id: self.id, power_value_change: 0, pawn_value_change: pawn_value_change)
      a.save unless options[:dry_run]

      # Not really enhanced
      list << a
    end
    list
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