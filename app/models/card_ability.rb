##
# Record to save the abilities of a card with attributes like type, when, which, action_type, :action_value.
# Card Ability TODOs:
# [ ] take into account when as it depends at the range of effect time when this card is played.
# [ ] find the affected other tiles dynamically other than Affected (CardTile), for examples, enhanced_allies enfeebled_enemies
# [ ] implement the non-integer action_value, for examples, ally.power, 
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


  # Either flip the claiming_user_id or add pawn_value to the tile.
  # This assumes source_tile.claiming_user_id is already set w/ GameMove#user_id.
  # This does not save the target_tile, just sets the attributes.
  # To skip saving the record changes, provide @options[:dry_run] = true.
  def self.apply_pawn_tile_effect(source_tile, target_tile, options = {})
    game_move_user_id = source_tile.claiming_user_id
    next_pawn_value = if (target_tile.claiming_user_id.nil? || target_tile.claiming_user_id == game_move_user_id) && target_tile.pawn_value < GameBoardTile::MAX_PAWN_VALUE
        target_tile.pawn_value.to_i + 1
      else
        target_tile.pawn_value
      end
    target_tile.attributes = {
      pawn_value: next_pawn_value, claiming_user_id: game_move_user_id, claimed_at: Time.now }
    target_tile.save unless options[:dry_run]
  end

  # Most basic: use self.class.apply_pawn_tile_effect
  # Subclasses override of this could be used to apply more complex effects.
  # This assumes source_tile.claiming_user_id is already set w/ GameMove#user_id.
  # This assumes the claiming_user_id is the same as the source_tile.claiming_user_id.
  # This sets the attribute values, but not saving @target_tile.
  # @source_tile <GameBoardTile> the tile where the card is played from.
  # @target_tile <GameBoardTile> the tile where the card is applied to.
  # @options <Hash> additional options such as :dry_run [Boolean] if true, would not save records.
  # @return <Array of GameBoardTileAbility> newly passed affected abilities from @source_tile to @target_tile.
  def apply_effect_to_tile(source_tile, target_tile, options = {})
    self.class.apply_pawn_tile_effect(source_tile, target_tile, options)
    []
  end

  # Check if this ability is applicable to the target_tile based on @source_tile and @which.
  def is_applicable_to_tile_by_which?(source_tile, target_tile)
    return false if source_tile.nil? || target_tile.nil? || source_tile.game_id != target_tile.game_id
    case which
    when 'self'
      source_tile.id == target_tile.id
    when 'allies_on_affected_tiles'
      source_tile.claiming_user_id == target_tile.claiming_user_id && source_tile.id != target_tile.id
    when 'enemies_on_affected_tiles'
      target_tile.claiming_user_id && source_tile.claiming_user_id != target_tile.claiming_user_id && source_tile.id != target_tile.id
    when 'allies_and_enemies_on_affected_tiles'
      target_tile.claiming_user_id && source_tile.id != target_tile.id
    when 'enhanced_allies'
      source_tile.claiming_user_id == target_tile.claiming_user_id && source_tile.id != target_tile.id && target_tile.enhanced?
    when 'enhanced_enemies'
      target_tile.claiminer_user_id && source_tile.claiming_user_id != target_tile.claiming_user_id && source_tile.id != target_tile.id && target_tile.enhanced?
    when 'enfeebled_allies'
      source_tile.claiming_user_id == target_tile.claiming_user_id && source_tile.id != target_tile.id && target_tile.enfeebled?
    when 'enfeebled_enemies'
      target_tile.claiming_user_id && source_tile.claiming_user_id != target_tile.claiming_user_id && source_tile.id != target_tile.id && target_tile.enfeebled?
    when 'enhanced_allies_and_enemies'
      target_tile.claiming_user_id && source_tile.id != target_tile.id && target_tile.enhanced?
    when 'enfeebled_allies_and_enemies'
      target_tile.claiming_user_id && source_tile.id != target_tile.id && target_tile.enfeebled?
    when 'positions'
      true
    when 'empty_positions'
      target_tile.claiming_user_id.nil?
    else
      false
    end
  end

  # @return <nil, Integer, ActiveRecord::Base or Array of ActiveRecord> the evaluated action_value.
  def action_value_evaluated(target_tile)
    return nil if action_value.blank?
    if action_value =~ /\A\d+\z/
      action_value.to_i
    elsif action_value == 'ally.power'
      target_tile.power_value.to_i
    elsif action_value == /Card\.\w+/ # Card.find or Card.where
      eval(action_value)
    end
  end

  def when_initially?
    %w(played in_play).include?(self.when)
  end

  # Used to have action before being broken to action_type and action_value is complete.
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

  # Used to have action before being broken to action_type and action_value is complete.
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