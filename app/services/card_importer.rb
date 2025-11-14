class CardImporter
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
      card = Card.find_by(card_number: h['card_number'])
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
end