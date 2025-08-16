class EnfeebleAbility < CardAbility

  validate :check_action_value

  # To skip saving the record changes, provide @options[:dry_run] = true.
  def apply_effect_to_tile(source_tile, target_tile, options = {})
    list = [] # super(source_tile, target_tile)
    if action_value 
      if action_type == 'power_down'
        # where action_value=ally.power would mean double power.
        power_value_change = action_value_evaluated(target_tile).to_i
        target_tile.power_value = target_tile.power_value.to_i + power_value_change
        
        a = target_tile.affected_tiles_to_abilities.new(source_game_board_tile_id: source_tile.id, 
              card_ability_id: self.id, power_value_change: power_value_change, pawn_value_change: 0)
        a.save unless options[:dry_run]

        if target_tile.power_value <= 0
          target_tile.apply_after_card_event(CardEvent.new(target_tile.game, target_tile.current_card, 'destroyed', options))
        else
          target_tile.apply_after_card_event(CardEvent.new(target_tile.game, target_tile.current_card, 'enfeebled', options))
        end
        list << a
      end
    end
    list
  end

  # Enfeeble ability reduces power.
  def action_value_evaluated(target_tile)
    power_value_change = super(target_tile)
    power_value_change = -1 * power_value_change if power_value_change > 0 # maybe data input wrong
    power_value_change
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