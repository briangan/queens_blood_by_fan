class EnfeebleAbility < CardAbility

  validate :check_action_value

  def apply_effect_to_tile(source_tile, target_tile, options = {})
    list = super(source_tile, target_tile)
    if action_value 
      if action_type == 'power_down'
        # where action_value=ally.power would mean double power.
        power_value_change = action_value_evaluated(target_tile).to_i
        power_value_change = -1 * power_value_change if power_value_change > 0 # Enfeeble ability reduces power
        target_tile.power_value = target_tile.power_value.to_i + power_value_change
        if target_tile.power_value <= 0
          target_tile.current_card_id = target_tile.current_card = nil
        end
        a = target_tile.game_board_tiles_abilities.new(source_game_board_tile_id: source_tile.id, 
              card_ability_id: self.id, power_value_change: power_value_change, pawn_value_change: 0)
        a.save unless options[:dry_run]
        list << a
      end
    end
    list
  end

  def check_action_value
    if action_value == 'ally.power' || action_value.to_i > 0
      true
    else
      self.errors.add(:action_value, 'must be either "ally.power" or a positive integer')
    end
  end

  def normalize_data
    super()
    self.when = 'played' if self.when.blank?
    self.action_type = 'power_down'
  end
end