class EnhanceAbility < CardAbility
  validate :check_action_value

  # To skip saving the record changes, provide @options[:dry_run] = true.
  def apply_effect_to_tile(source_tile, target_tile, options = {})
    list = [] # super(source_tile, target_tile, options)
    if action_value && target_tile
      if action_type == 'power_up'
        # where action_value=ally.power would mean double power.
        power_value_change = action_value_evaluated(target_tile).to_i
        target_tile.power_value = target_tile.power_value.to_i + power_value_change
        a = target_tile.affected_tiles_to_abilities.new(source_game_board_tile_id: source_tile.id, 
              card_ability_id: self.id, power_value_change: power_value_change, pawn_value_change: 0)
        a.save unless options[:dry_run]

        target_tile.apply_after_card_event(CardEvent.new(target_tile.game, target_tile.current_card, 'enfeebled', options))
        list << a
      end
    end
    list
  end

  def check_action_value
    if action_value == 'ally.power' || action_value == 'victor_receives_all_scores' || action_value.to_i > 0
      true
    else
      self.errors.add(:action_value, 'must be either "ally.power" or a positive integer')
      false
    end
  end

  def normalize_data
    super()
    self.when = 'played' if self.when.blank?
    self.action_type = 'power_up' if %(raise_rank power_up ).exclude?(action_type)
  end
end