##
# Record to save the abilities of a card with attributes like type, when, which and action.
class CardAbility < ApplicationRecord
  belongs_to :card
  attr_accessor :action_type, :action_value

  TYPES = %w[EnhanceAbility EnfeebleAbility ReplacementAbility SpawnAbility AddCardAbility DestroyCardAbility]
  WHEN_VALUES = %w[initiated played destroyed enhanced enfeebled]
  WHICH_VALUES = %w[allies_on_affected_tiles enemies_on_affected_tiles enhanced_allies enhanced_enemies enfeebled_allies enfeebled_enemies empty_positions]
  ACTION_TYPES = %w[power_up power_down spawn add destroy]
  ACTION_TYPE_TO_CLASS_TYPE = { 'power_up' => 'EnhanceAbility', 'power_down' => 'EnfeebleAbility', 'spawn' => 'SpawnAbility', 'add' => 'AddCardAbility', 'destroy' => 'DestroyCardAbility' }
  OPERATOR_TO_ACTION_TYPE = { '+' => 'power_up', '-' => 'power_down' }

  ACTION_REGEXP = /([\w]+)\s*([\-\+])?\s*([\s\w]+)?/i

  validates_presence_of :card_id, :type

  before_save :normalize_data

  def action_type
    return nil if action.blank?
    m = action.match(ACTION_REGEXP)
    return nil if m.nil?
    first_word = m[1].strip.downcase
    if first_word == 'power'
      return OPERATOR_TO_ACTION_TYPE[m[2]]
    else
      return first_word
    end
  end

  def action_value
    return nil if action.blank?
    m = action.match(ACTION_REGEXP)
    return nil if m.nil? || m[2].blank?
    if m[1] == 'power' || m[1] == 'spawn' || m[1] == 'add'
      return m[3]
    else
      return m[2]
    end
  end

  protected 

  def normalize_data
    self.type = ACTION_TYPE_TO_CLASS_TYPE[action_type&.downcase] || 'CardAbility' if type.blank?
    self.when = self.when&.downcase
    self.which = self.which&.downcase
  end
end