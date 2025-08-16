class CleanDuplicateCardTilesByPosition < ActiveRecord::Migration[7.2]
  def change
    Card.includes(:card_tiles).all.each do|c| 
      grouped_by_positions = c.card_tiles.all.group_by{|ct| [ct.x, ct.y] }
      next unless c.card_tiles.size > grouped_by_positions.size
      grouped_by_positions.each do|xy, card_tiles|
        if card_tiles.find{|ct| ct.is_a?(Affected) } && (pawns = card_tiles.find_all{|ct| ct.is_a?(Pawn) }).size > 0
          puts "Card #{c.id} has an Affected CardTile at position #{xy.inspect}."
          puts "  Pawns #{pawns.size} at position #{xy.inspect}."
          pawns.each(&:destroy)
        end
      end
    end
  end
end
