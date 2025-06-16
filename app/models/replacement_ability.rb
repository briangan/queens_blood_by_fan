class ReplacementAbility < CardAbility

  def normalize_data
    super()
    self.type = 'ReplacementAbility'
    self.when = 'played'
    self.which ||= 'self' if which.blank?
    self.action_type ||= 'destroy' if action_type.blank?
  end
end