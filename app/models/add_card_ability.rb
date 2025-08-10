class AddCardAbility < CardAbility

  validate :check_card_to_add

  def apply_effect_to_tile(source_tile, target_tile)
    super(source_tile, target_tile)
    if source_tile.current_card && source_tile.current_turn_user_id
      new_card = action_value_evaluated(target_tile)
      # TODO: need DB record to map a game usable cards for players.
      if new_card.is_a?(Card)
      elsif new_card.is_a?(Array)
      end
      # Assuming action_value is a card name or ID, we would add the card to the target tile.
      target_tile.current_card = new_card
      target_tile.save
    end
  end

  def check_card_to_add
    # TODO: Check if the card exists in the database

    if self.action_type == 'add' && self.action_value.present? 
      true
    else
      self.errors.add(:action_value, 'must be a valid card name')
      false
    end
  end

  def normalize_data
    super()
    self.when = 'played' if self.when.blank?
    self.action_type ||= 'add' if action_type.blank?
  end
end