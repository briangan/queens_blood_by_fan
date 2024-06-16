##
# Record to save the abilities of a card with attributes like type, when, which, action_type, :action_value.
# Card Ability TODOs:
# [ ] Card number 32 has when "allied cards are played from hand", which "self"
# [ ] Card number 35 has when "allied cards are destroy", which "self"
# [ ] Card number 38 has when "enemy cards are played from hand", which "self"
class CardAbility < ApplicationRecord
  belongs_to :card
  # attr_accessor :action

  TYPES = %w[EnhanceAbility EnfeebleAbility ReplacementAbility SpawnAbility AddCardAbility DestroyCardAbility]
  WHEN_VALUES = %w[played in_play destroyed enhanced enfeebled allies_played_from_hand enemies_played_from_hand allies_destroyed enemies_destroyed allies_and_enemies_destroyed win_the_lane]
  WHICH_VALUES = %w[self allies_on_affected_tiles enemies_on_affected_tiles allies_and_enemies_on_affected_tiles enhanced_allies enhanced_enemies enfeebled_allies enfeebled_enemies empty_positions]
  ACTION_TYPES = %w[power_up power_down spawn add destroy]
  ACTION_TYPE_TO_CLASS_TYPE = { 'power_up' => 'EnhanceAbility', 'power_down' => 'EnfeebleAbility', 'spawn' => 'SpawnAbility', 'add' => 'AddCardAbility', 'destroy' => 'DestroyCardAbility' }
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