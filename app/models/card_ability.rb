##
# Record to save the abilities of a card with attributes like type, when, which, action_type, :action_value.
# Card Ability TODOs:
# [ ] Card number 66 has multiple abilities
# [ ] Card number 86 has ability "when first reaches power 7 ..."
# [ ] Card number 142 has ability "when the rounds ends, the loser of each lane's score is added to victor's"
class CardAbility < ApplicationRecord
  belongs_to :card, optional: true
  # attr_accessor :action

  TYPES = %w[RaiseRankAbility EnhanceAbility EnfeebleAbility ReplacementAbility SpawnAbility AddCardAbility DestroyCardAbility]
  WHEN_VALUES = %w[played in_play destroyed enhanced enfeebled allies_played_from_hand enemies_played_from_hand allies_destroyed enemies_destroyed allies_and_enemies_destroyed win_the_lane win_the_round power_first_reaches_7]
  WHICH_VALUES = %w[self allies_on_affected_tiles enemies_on_affected_tiles allies_and_enemies_on_affected_tiles enhanced_allies enhanced_enemies enfeebled_allies enfeebled_enemies enhanced_allies_and_enemies enfeebled_allies_and_enemies positions empty_positions]
  ACTION_TYPES = %w[raise_rank power_up power_down spawn add destroy victor_receives_all_scores]
  ACTION_TYPE_TO_CLASS_TYPE = { 'raise_rank' => 'RaiseRankAbility', 'power_up' => 'EnhanceAbility', 'power_down' => 'EnfeebleAbility', 'spawn' => 'SpawnAbility', 'add' => 'AddCardAbility', 'destroy' => 'DestroyCardAbility', 'victor_receives_all_scores' => 'VictorReceivesAllScoresAbility' }
  OPERATOR_TO_ACTION_TYPE = { '+' => 'power_up', '-' => 'power_down' }
  PERMITTED_PARAMS = [:card_id, :type, :when, :which, :action_type, :action_value]

  ACTION_REGEXP = /([\w]+)\s*([\-\+])?\s*([\s\w]+)?/i

  validates_presence_of :card_id, :type

  before_save :normalize_data

  # TODO: Remove this method when ensure migration from action to action_type and action_value is complete.
  def parsed_action_type
    return nil if !self.respond_to?(:action) || action.blank?
    m = action.match(ACTION_REGEXP)
    return nil if m.nil?
    first_word = m[1].strip.downcase
    if first_word == 'power'
      return OPERATOR_TO_ACTION_TYPE[m[2]]
    else
      return first_word
    end
  end

  # TODO: Remove this method when ensure migration from action to action_type and action_value is complete.
  def parsed_action_value
    return nil if !self.respond_to?(:action) || action.blank?
    m = action.match(ACTION_REGEXP)
    return nil if m.nil? || m[2].blank?
    if m[1] == 'power' || m[1] == 'spawn' || m[1] == 'add'
      return m[3]
    else
      return m[2]
    end
  end 

  def normalize_data
    self.type = ACTION_TYPE_TO_CLASS_TYPE[action_type&.downcase] || 'CardAbility' if action_type.present?
    self.when = self.when&.downcase
    self.which = self.which&.downcase
  end
end