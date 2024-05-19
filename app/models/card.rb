##
# Record that represents a card to be used by a player with attributes like name, card_number, pawn_rank, and power.
# Associations include tiles and abilities.
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

  def pawn_tiles_data
    # card_tiles.map { |tile| [tile.x, tile.y] }
    pawn_tiles.is_a?(Array) ? pawn_tiles :
      [ [0, 1], [1, 0], [0, -1], [-1, 0] ] # TODO: sample data
  end

  def affected_tiles_data
    affected_tiles.is_a?(Array) ? affected_tiles :
      [ [1, 1], [2, 0] ] # TODO: sample data
  end

  def tiles_map
    m = {}
    pawn_tiles_data.each do|pair|
      m[pair] = 'pawn'
    end
    affected_tiles_data.each do|pair|
      m[pair] = 'affected'
    end
    m
  end

  def ability_effects_data
    # card_ability.map { |ability| ability.attributes }
    [ { type: 'EnhancementAbility', when: 'initiated', which: 'allies_on_affected_tiles', action: 'power + 3' } ]
  end

  ###########################
  # Class methods

  ##
  # @h [Hash] data from import file, like YAML
  # @return <Card or subclass> instance
  def self.build_from_import_data(h)
    card_class = h['type'].constantize
    card = card_class.new(name: h['name'], card_number: h['card_number'], pawn_rank: h['pawn_rank'], power: h['power'])
    card.pawn_tiles = h['pawn_tiles']
    card.affected_tiles = h['affected_tiles']
    card.ability_effects = h['ability_effects']
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