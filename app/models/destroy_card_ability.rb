class DestroyCardAbility < CardAbility

  def apply_effect_to_tile(source_tile, target_tile, options = {})
    target_tile.current_card = nil
    target_tile.current_card_id = nil
    target_tile.claiming_user_id = source_tile.claiming_user_id
    target_tile.save unless options[:dry_run]
  end
end