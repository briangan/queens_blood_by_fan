class VictorReceivesAllScoresAbility < CardAbility
  def normalize_data
    super()
    self.action_value = 'all.power'
  end
end