##
# Record to save the abilities of a card with attributes like type, when, which and action.
class CardAbility < ApplicationRecord
  belongs_to :card

  TYPES = %w[EnhanceAbility EnfeebleAbility ReplacementAbility SpawnAbility AddCardAbility DestroyCardAbility]
  WHEN_VALUES = %w[initiated played destroyed enhanced enfeebled]
  WHICH_VALUES = %w[allies_on_affected_tiles enemies_on_affected_tiles enhanced_allies enhanced_enemies enfeebled_allies enfeebled_enemies empty_positions]

  validates_presence_of :card_id, :type
end