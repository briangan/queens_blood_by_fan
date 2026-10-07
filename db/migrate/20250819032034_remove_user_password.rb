class RemoveUserPassword < ActiveRecord::Migration[7.2]
  def up
    remove_column_if_exists :users, :password, :string
  end

  def down
    add_column :users, :password, :string, limit: 128
  end
end
