##
# Record that represents a card to be used by a player with attributes like name, card_number, pawn_rank, and power.
# Associations include tiles and abilities.
# Cards TODOs:
# [x] Add Mandragora Minion card
# [x] Add Heatseeker Minion card
# [ ] Add Grangalan Junior card
# [ ] Add Resurrected Amalgam card
# [ ] Add Moogle card
# [ ] Add Tiny Bronco card
# [ ] Add Galian Beast card
# [ ] Add Diamond Dust card, can be power 2, 4, or 6
# [ ] Add Elemental card
# [ ] Add Moogle Mage card
# [ ] Add Moogle Bard cards
# [ ] Add Cacneo card
# [ ] Add Donberry card
# [ ] Add Hype Johnny card
class Card < ApplicationRecord
  has_many :card_abilities, dependent: :destroy
  has_many :card_tiles, dependent: :destroy
  has_many :pawn_tiles, -> { where(type: 'Pawn') }, class_name: 'Pawn'
  has_many :affected_tiles, -> { where(type: 'Affected') }, class_name: 'Affected'

  attr_accessor :ability_effects

  validates_presence_of :name

  before_save :normalize_data

  TYPES = %w[Card ReplacementCard]
  CATEGORIES = %w[Standard Legendary]

  # 'Ying & Yang' to 'ying-yang'
  def dash_id
    name.gsub(/[^a-z0-9]+/i, '-').downcase
  end

  ##
  # @return [Array] of [x, y] coordinates of pawn tiles
  def pawn_tiles_data
    pawn_tiles.map { |tile| [tile.x, tile.y] }
  end

  ##
  # @return [Array] of [x, y] coordinates of affected tiles
  def affected_tiles_data
    affected_tiles.map { |tile| [tile.x, tile.y] }
  end

  ##
  # @return [Hash] with keys as [x, y] and values as tile type downcased
  def card_tiles_map
    m = {}
    card_tiles.each do|tile|
      m[[tile.x, tile.y]] = tile.type.underscore
    end
    m
  end

  ##
  # Only for testing.
  def ability_effects_data
    card_abilities.map { |ability| ability.attributes }
    # [ { type: 'EnhancementAbility', when: 'initiated', which: 'allies_on_affected_tiles', action: 'power + 3' } ]
  end

  ##
  # @tile_data <Hash or ActionController::Parameters> with keys as [x, y] and values as tile type downcased
  def update_card_tile_selections(tile_data, erase_existing = true)
    return unless tile_data.is_a?(ActionController::Parameters) || tile_data.is_a?(Hash)
    if erase_existing
      self.card_tiles.delete_all
    end
    tile_data.each_pair do |k, v|
      x, y = k.split('_').map(&:to_i)
      self.card_tiles.create(type: v.classify, x: x, y: y)
    end
  end

  ##
  # @abilities_data <Array of Hash> with keys as [][x, y] and values as tile type downcased.
  #   action can be represented either directly by 'action' => 'power + 3' or by 'action_type' => 'power_up' and 'action_value' => '3'
  def update_card_abilities(abilities_data, erase_existing = true)
    return 0 unless abilities_data.is_a?(ActionController::Parameters) || abilities_data.present?
    if erase_existing
      self.card_abilities.delete_all
    end
    abilities_data.collect do |ability_data|
      ability = self.card_abilities.new(ability_data.slice(:type, :when, :which, :action_type, :action_value))
      ability.normalize_data
      logger.debug("> #{ability.class} valid? #{ ability.valid? }")
      ability.save
    end
  end

  def clean_card_tiles!
    existing_set = Set.new
    card_tiles.each do|t| 
      a = [t.type, t.x, t.y]
      if existing_set.include?(a)
        t.destroy
      else
        existing_set << a
      end
    end
  end

  def yaml_data
    h = attributes.slice(*%w(type name category card_number description power_rank power raise_power_rank) )
    h['cars_tiles'] = self.card_tiles.collect{|t| t.attributes.slice('type', 'x', 'y') }
    h['abilities'] = self.card_abilities.collect{|a| a.attributes.slice('type', 'when', 'which', 'action_type', 'action_value') }
    h
  end

  ###########################
  # Class methods

  ##
  # @h [Hash] data from import file, like YAML
  # @return <Card or subclass> instance
  def self.build_from_import_data(h)
    card_class = h['type'].constantize
    card = card_class.new(name: h['name'], card_number: h['card_number'], pawn_rank: h['pawn_rank'], power: h['power'])
    card.card_tiles = h['card_tiles'].to_a.collect{|t| CardTile.new(t) }
    card.pawn_tiles = h['pawn_tiles'].to_a.collect{|t| Pawn.new(t) }
    card.affected_tiles = h['affected_tiles'].to_a.collect{|t| AffectedTile.new(t) }
    card.card_abilities = h['card_abilities'].to_a.collect{|a| CardAbility.new(a) }
    card
  end

  def self.import_from_file(file_path = nil)
    file_path ||= File.join(Rails.root, 'data/cards.yml')
    data = YAML.load_file(file_path)
    data.each do |h|
      card = find_by(card_number: h['card_number'])
      card ||= build_from_import_data(h)
      card.save
      card.card_tiles.delete_all
      if h['pawn_tiles'].is_a?(Array)
        h['pawn_tiles'].each do |t|
          card.card_tiles.create(type:'Pawn', x: t[0], y: t[1])
        end
      end
      if h['affected_tiles'].is_a?(Array)
        h['affected_tiles'].each do |t|
          card.card_tiles.create(type:'Affected', x: t[0], y: t[1])
        end
      end

      card.card_abilities.delete_all
      if h['abilities'].is_a?(Array)
        h['abilities'].each do |a|
          card.card_abilities.create(a)
        end
      end
    end
  end

  private

  def normalize_data
    self.type ||= 'Card'
    self.pawn_rank = -1 if pawn_rank.nil? || type == 'ReplacementCard'
  end
end

class Replacement

end