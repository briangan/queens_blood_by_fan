class SeparateActionInCardAbilities < ActiveRecord::Migration[7.1]
  def up
    add_column_unless_exists :card_abilities, :action_type, :string, limit: 64
    add_column_unless_exists :card_abilities, :action_value, :string, limit: 64
    CardAbility.all.each do |ability|
      ability.action_type = ability.parsed_action_type
      ability.action_value = ability.parsed_action_value
      ability.save
    end
    remove_column_if_exists :card_abilities, :action
  end

  def down
    add_column_unless_exists :card_abilities, :action, :string, limit: 128
    CardAbility.all.each do |ability|
      ability.action = "#{ability.action_type} #{ability.action_value}"
      ability.save
    end
    remove_column_if_exists :card_abilities, :action_type
    remove_column_if_exists :card_abilities, :action_value
  end
end
