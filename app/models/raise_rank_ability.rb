class RaiseRankAbility < CardAbility
  validate :check_action_value

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