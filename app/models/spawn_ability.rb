# Some card can spawn other cards to be placed on certain tiles.  Different from AddCardAbility.
class SpawnAbility < CardAbility
  # To skip saving the record changes, provide @options[:dry_run] = true.
  def apply_effect_to_tile(source_tile, target_tile, options = {})
    list = super(source_tile, target_tile)
    power_value_change = action_value_evaluated(target_tile).to_i
    if source_tile.current_card && (child_card = source_tile.current_card.children_cards.first)
      target_tile.current_card = child_card
      target_tile.power_value = target_tile.power_value.to_i + power_value_change
      target_tile.save unless options[:dry_run]
      logger.info "\\ ca #{self.type} spawned card #{child_card.name} w/ #{power_value_change} power to tile(#{target_tile.id}) [#{target_tile.column}, #{target_tile.row}]"
      a = target_tile.affected_tiles_to_abilities.new(source_game_board_tile_id: source_tile.id, 
            card_ability_id: self.id, power_value_change: power_value_change, pawn_value_change: 0)
      a.save unless options[:dry_run]
      list << a
    end
    list
  end

end