class AddParentIdToCards < ActiveRecord::Migration[7.2]
  def up
    add_column_unless_exists :cards, :parent_card_id, :integer, null: true, default: nil
    add_index_unless_exists :cards, [:parent_card_id]
  end

  def down
    remove_index_if_exists :cards, [:parent_card_id]
    remove_column_if_exists :cards, :parent_card_id
  end
end
