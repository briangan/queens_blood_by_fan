module CardAbilitiesHelper
  def card_ability_type_select_options
    [['', '']] + CardAbility::TYPES.map { |t| [t.gsub(/Ability$/, ''), t ] }
  end

  def card_ability_when_select_options
    CardAbility::WHEN_VALUES.map { |t| [t.titleize, t] }
  end

  def card_ability_which_select_options
    CardAbility::WHICH_VALUES.map { |t| [t.titleize, t] }
  end

  def card_ability_action_type_select_options
    CardAbility::ACTION_TYPES.map { |t| [t.titleize, t] }
  end

  def card_ability_action_value_select_options
    [['', '']] + (1..10).map { |n| [n, n] }
  end
end