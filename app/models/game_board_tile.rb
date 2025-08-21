##
# Data of a board spot which can be empty or placed with a card.
class GameBoardTile < ApplicationRecord
  MAX_PAWN_VALUE = 3
  
  has_paper_trail on: [:update]

  belongs_to :game, dependent: :destroy, optional: true
  belongs_to :board, optional: true
  
  belongs_to :current_card, class_name:'Card', optional: true
  belongs_to :claiming_user, class_name: 'User', foreign_key: 'claming_user_id', optional: true

  has_many :affected_tiles_to_abilities, class_name:'AffectedTileToAbility', dependent: :destroy
  
  # Based on some other card(s)'s card abilities affecting this tile.
  has_many :affecting_card_abilities, class_name: 'CardAbility', source: :card_ability, through: :affected_tiles_to_abilities

  # Scopes
  scope :claimed, -> { where('claming_user_id IS NOT nil') }

  # Validations
  validates_presence_of :game_id, :board_id, :column, :row

  # before and after callbacks
  before_save :normalize_attributes

  def to_s
    "<GameBoardTile #{id}: [#{column}, #{row}]>"
  end

  ##
  # The HTML data attributes for this tile.
  def cell_data_attr
    { 
      'tile-position' => "#{column},#{row}", 'game-board-tile-id' => "#{id}", 
      'claiming-user-id' => "#{claiming_user_id}", 'pawn-value' => "#{pawn_value}"
    }
  end

  def power_value_total_change
    affected_tiles_to_abilities.collect(&:power_value_change).compact.sum
  end

  def power_raised?
    power_value_total_change > 0
  end

  def power_lowered?
    power_value_total_change < 0
  end

  def enhanced?
    affected_tiles_to_abilities.find{|ca| ca.power_value_change > 0 } != nil
  end

  def enfeebled?
    affected_tiles_to_abilities.find{|ca| ca.power_value_change < 0 } != nil
  end

  def raised?
    affected_tiles_to_abilities.find{|ca| ca.pawn_value_change > 0 } != nil
  end

  def claiming_player_number
    game.which_player_number(claiming_user_id)
  end

  # Current card + all card abilities affecting this tile.
  # Record not saved, just the attributes are set.
  def recalculate_power_value
    self.power_value = current_card&.power&.to_i + power_value_total_change
  end

  ##
  # A CardAbility has attributes when, which, action_type, action_value.
  # This method finds all tiles affected by a specific card event.
  # If CardAbility 'played', it affects all tiles w/ when 'played' or 'in_play'.
  # But 'which' tiles would not only be on static CardTile but possibly dynamic ones like 'empty_positions'.
  # And some cards might have Affected CardTile.
  # @yield <CardTile, GameBoardTile>
  # @return <Array of <GameBoardTile>> the same ones being yield.
  def for_each_related_tile_affected_by_card_ability(card_event, &block)
    list = []
    x_sign = (card_event.game.which_player_number(claiming_user_id) == 2) ? -1 : 1
    card_tile_conds = nil
    if card_event.card_event == 'played'
      card_tile_conds = "card_abilities.'when' IN ('played', 'in_play')"
    else
      card_tile_conds = "card_abilities.'when' NOT IN ('played')"
    end

    card_event.card.card_tiles.each do|card_tile|
      legit_tile = nil
      if card_tile.is_a?(Affected)

        card_event.card.card_abilities.where(card_tile_conds).each do |ca|
          if ca.which.blank? || ca.which =~ /^(\w+)_on_affected_tiles$/
            other_t = card_event.game.find_tile(column + card_tile.x * x_sign, row + card_tile.y)            
            if ca.blank? || ca.which == 'allies_on_affected_tiles'
              legit_tile = other_t if other_t && claiming_user_id == other_t.claiming_user_id
            elsif $1 == 'enemies'
              legit_tile = other_t if other_t&.claiming_user_id && claiming_user_id != other_t.claiming_user_id
            elsif $1 == 'allies_and_enemies'
              legit_tile = other_t if other_t&.claiming_user_id
            end
          end
        end # each CardAbility
        
      else # Pawn tile

        legit_tile = card_event.game.find_tile(column + card_tile.x * x_sign, row + card_tile.y)

      end

      if legit_tile
        list << legit_tile
        yield card_tile, legit_tile if block_given?
      end
    end # each CardTile

    # Some which not based on preset tiles:
    # enhanced_allies enhanced_enemies enfeebled_allies enfeebled_enemies enhanced_allies_and_enemies enfeebled_allies_and_enemies positions empty_positions
    if current_card && current_card.card_tiles.size == 0
      card_event.card.card_abilities.where(card_tile_conds).each do |ca|
        case ca.which
        when 'enhanced_allies'
          card_event.game.game_board_tiles.includes(:affected_tiles_to_abilities).where(claiming_user_id: claiming_user_id).each do |other_t|
            next unless other_t.enhanced?
            list << other_t
            yield nil, other_t if block_given?              
          end
        when 'enhanced_enemies'
          card_event.game.game_board_tiles.includes(:affected_tiles_to_abilities).where(claiming_user_id: game.the_other_player_user_id(claiming_user_id)).each do |other_t|
            next unless other_t.enhanced?
            list << other_t
            yield nil, other_t if block_given?
          end
        when 'enfeebled_allies'
          card_event.game.game_board_tiles.includes(:affected_tiles_to_abilities).where(claiming_user_id: claiming_user_id).each do |other_t|
            next unless other_t.enfeebled?
            list << other_t
            yield nil, other_t if block_given?
          end
        when 'enfeebled_enemies'
          card_event.game.game_board_tiles.includes(:affected_tiles_to_abilities).where(claiming_user_id: game.the_other_player_user_id(claiming_user_id)).each do |other_t|
            next unless other_t.enfeebled?
            list << other_t
            yield nil, other_t if block_given?
          end
        when 'enhanced_allies_and_enemies'
          card_event.game.game_board_tiles.includes(:affected_tiles_to_abilities).where("claiming_user_id IS NOT NULL").each do |other_t|
            next unless other_t.enhanced?
            list << other_t
            yield nil, other_t if block_given?
          end
        when 'enfeebled_allies_and_enemies'
          card_event.game.game_board_tiles.includes(:affected_tiles_to_abilities).where("claiming_user_id IS NOT NULL").each do |other_t|
            next unless other_t.enfeebled?
            list << other_t
            yield nil, other_t if block_given?
          end
        when 'positions'
          card_event.game.game_board_tiles.includes(:affected_tiles_to_abilities).where("claiming_user_id IS NULL").each do |other_t|
            list << other_t
            yield nil, other_t if block_given?
          end
        when 'empty_positions'
          card_event.game.game_board_tiles.includes(:affected_tiles_to_abilities).where("claiming_user_id=? AND current_card_id IS NULL", self.claiming_user_id).each do |other_t|
            list << other_t
            yield nil, other_t if block_given?
          end
        end
      end
    end
    list
  end

  ##
  # To be called after a card event is applied to this tile, not only card being placed but also
  # other effects like enhanced, enfeebled or destroyed, etc.
  # According to certain change to a card on this tile, processes the associated CardAbility inside affected_tiles_to_abilities.
  # Please set claiming_user_id to provide context of which is current player
  # To skip saving the record changes, provide @options[:dry_run] = true.
  # @card_event <CardEvent>
  #   :dry_run <Boolean> if true, do not persist changes
  # @yield <CardTile>, <GameBoardTile> the other affected tiles
  def apply_after_card_event(card_event, &block)
    unless card_event && card_event.card && card_event.card_event
      logger.error "apply_after_card_event: card_event is not valid: #{card_event.inspect}"
      return
    end
    case card_event.card_event
      when 'played'
        apply_played_card_event(card_event, &block)

      when 'destroyed'
        logger.info "\\ apply_after_card_event destroyed card #{card_event.card&.name} from #{self}"
        apply_destroyed_card_event(card_event, &block)

      when 'enhanced'

      when 'enfeebled'

    end
  end

  ACCEPTABLE_ABILITY_WHICH_FOR_PAWN_TILES = ['positions', 'empty_positions']

  def apply_played_card_event(card_event, &block)
    x_sign = (card_event.game.which_player_number(claiming_user_id) == 2) ? -1 : 1
    dry_run = card_event.dry_run?
    for_each_related_tile_affected_by_card_ability(card_event) do |card_tile, other_t|
      # next if card_tile.x.to_i < 1 && card_tile.y.to_i < 1

      logger.info "| card_tile: #{card_tile&.x} + x #{card_tile&.x.to_i * x_sign}, #{row} + y #{row + card_tile&.y.to_i} => #{other_t&.as_json}"
      if card_tile.is_a?(Affected)
        # Pass the card ability to the tile.
        card_event.card.card_abilities.each do |ca|
          next unless ca.when_initially?
          ca_changes = ca.apply_effect_to_tile(self, other_t, dry_run: dry_run)
          logger.info " \\_ ca_changes for #{ca.type}: #{ca_changes.as_json }"
        end
      else # Pawn
        # Pawn tile, just set the pawn value.
        CardAbility.apply_pawn_tile_effect(self, other_t, dry_run: dry_run)

        card_event.card.card_abilities.each do |ca|
          next unless ACCEPTABLE_ABILITY_WHICH_FOR_PAWN_TILES.include?(ca.which)
          ca_changes = ca.apply_effect_to_tile(self, other_t, dry_run: dry_run)
          logger.info " \\_ ca_changes for #{ca.type}: #{ca_changes.as_json }"
        end
      end
      other_t.save unless dry_run

      yield card_tile, other_t if block_given?
        
    end
  end

  def apply_destroyed_card_event(card_event, &block)
    # Cancel abilities to affected tiles of current_card
    for_each_related_tile_affected_by_card_ability(card_event) do |card_tile, other_t|
      card_event.card.card_abilities.each do |ca|
        logger.info "    +- After destroyed_card, applying #{ca.type} to #{other_t.to_s}"
        ca.apply_effect_to_tile(self, other_t, dry_run: card_event.dry_run?)
      end
      other_t.save unless card_event.dry_run?
    end

    self.current_card_id = self.current_card = nil
    self.power_value = 0
    if card_event.dry_run?
      self.affected_tiles_to_abilities = []
    else
      self.affected_tiles_to_abilities.delete_all
      self.save
    end
  end

  private

  def normalize_attributes
    self.pawn_value = 1 if claiming_user_id && pawn_value.to_i < 1
  end
end