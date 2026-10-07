class ExtendActionValueOfCardAbilities < ActiveRecord::Migration[7.2]
  def change
    change_column :card_abilities, :action_value, :string, limit: 255, null: true
  end
  
end
