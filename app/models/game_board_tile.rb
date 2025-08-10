##
# Data of a board spot which can be empty or placed with a card.
class GameBoardTile < ApplicationRecord
  MAX_PAWN_VALUE = 3
  
  has_paper_trail on: [:update]

  belongs_to :game, dependent: :destroy, optional: true
  belongs_to :board, optional: true
  
  belongs_to :current_card, class_name:'Card', optional: true
  belongs_to :claiming_user, class_name: 'User', foreign_key: 'claming_user_id', optional: true

  has_many :game_board_tiles_abilities, class_name:'GameBoardTileAbility', dependent: :destroy
  
  # Based on some other card(s)'s card abilities affecting this tile.
  has_many :affecting_card_abilities, class_name: 'CardAbility', source: :card_ability, through: :game_board_tiles_abilities

  # Scopes
  scope :claimed, -> { where('claming_user_id IS NOT nil') }

  # Validations
  validates_presence_of :game_id, :board_id, :column, :row

  # before and after callbacks
  before_save :normalize_attributes

  ##
  # The HTML data attributes for this tile.
  def cell_data_attr
    { 
      'tile-position' => "#{column},#{row}", 'game-board-tile-id' => "#{id}", 
      'claiming-user-id' => "#{claiming_user_id}", 'pawn-value' => "#{pawn_value}"
    }
  end

  def power_value_total_change
    game_board_tiles_abilities.collect(&:power_value_change).compact.sum
  end

  def enhanced?
    game_board_tiles_abilities.find{|ca| ca.power_value_change > 0 } != nil
  end

  def enfeebled?
    game_board_tiles_abilities.find{|ca| ca.power_value_change < 0 } != nil
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
  def find_affected_tiles(card_event)
    affected_tiles = []
    card_tile_conds = nil
    if card_event == 'played'
      card_tile_conds = "card_abilities.when IN ('played', 'in_play')"
    end
    card_event.card.card_abilities.where(card_tile_conds).each do |ca|
      affected_tiles.concat(ca.find_affected_tiles(card_event))
    end
    affected_tiles
  end

  # According to certain change to a card on this tile, processes the associated CardAbility inside game_board_tiles_abilities.
  # Please set claiming_user_id to provide context of which is current player
  # To skip saving the record changes, provide @options[:dry_run] = true.
  # @card_event <CardEvent>
  #   :dry_run <Boolean> if true, do not persist changes
  # @yield <CardTile>, <GameBoardTile> the other affected tiles
  def apply_after_card_event(card_event, &block)
    case card_event.card_event
      when 'played'
        apply_played_card_event(card_event, &block)

      when 'destroyed'

        apply_destroyed_card_event(card_event, &block)

      when 'enhanced'

      when 'enfeebled'

    end
  end

  def apply_played_card_event(card_event, &block)
    x_sign = (card_event.game.which_player_number(claiming_user_id) == 2) ? -1 : 1
    dry_run = card_event.dry_run?
    card_event.card.card_tiles.each do |card_tile|
      # next if card_tile.x.to_i < 1 && card_tile.y.to_i < 1
      other_t = card_event.game.find_tile(column + card_tile.x * x_sign, row + card_tile.y)
      self.class.logger.info "| card_tile: #{column} + x #{card_tile.x * x_sign}, #{row} + y #{card_tile.y} => #{other_t&.as_json}"
      if other_t
        if card_tile.is_a?(Affected)
          # Pass the card ability to the tile.
          card_event.card.card_abilities.each do |ca|
            next unless ca.when_initially?
            ca_changes = ca.apply_effect_to_tile(self, other_t, dry_run: dry_run)
            self.class.logger.info " \\_ ca_changes for #{ca.type}: #{ca_changes.as_json }"
          end
        else # Pawn
          # Pawn tile, just set the pawn value.
          CardAbility.apply_pawn_tile_effect(self, other_t)
        end
        other_t.save unless dry_run

        yield card_tile, other_t if block_given?
          
      end
    end
  end

  def apply_destroyed_card_event(card_event, &block)
    # Cancel abilities to affected tiles of current_card
    if current_card
      current_card.card_abilities.each do |a|
        # TODO: a.card_ability.cancel_effect_on_tile(self, dry_run: options[:dry_run])
      end
    end
    self.current_card_id = self.current_card = nil

    # Effects to affected tiles
    game_board_tiles_abilities.joins(:card_ability).where("'when' LIKE '%destroyed'").each do |a|
      case a.when
        when 'destroyed'
                    
        when 'allies_destroyed'
        when 'enemies_destroyed'
        when 'allies_and_enemies_destroyed'
      end
    end
  end

  private

  def normalize_attributes
    self.pawn_value = 1 if claiming_user_id && pawn_value.to_i < 1
  end
end