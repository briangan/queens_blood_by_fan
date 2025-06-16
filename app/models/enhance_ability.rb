class EnhanceAbility < CardAbility
  validate :check_action_value

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