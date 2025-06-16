class VictorReceivesAllScoresAbility < CardAbility
  def normalize_data
    super()
    self.type = 'EhanceAbility'
    self.action_value = 'all.power'
  end
end