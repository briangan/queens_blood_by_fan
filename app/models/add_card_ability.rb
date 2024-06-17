class AddCardAbility < CardAbility

  validate :check_card_to_add

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