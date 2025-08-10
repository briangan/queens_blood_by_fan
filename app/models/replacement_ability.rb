class ReplacementAbility < CardAbility

  def apply_effect_to_tile(source_tile, target_tile, options = {})
    target_tile.pawn_value = target_tile.pawn_value
    target_tile.power_value = target_tile.power_value
  end


  def normalize_data
    super()
    self.type = 'ReplacementAbility'
    self.when = 'played'
    self.which ||= 'self' if which.blank?
    self.action_type ||= 'destroy' if action_type.blank?
  end
end