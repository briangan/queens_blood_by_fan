class RenameGamesCards < ActiveRecord::Migration[7.2]
  def change
    rename_table :games_cards, :game_cards
  end
end
