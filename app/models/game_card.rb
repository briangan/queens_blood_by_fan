class GameCard < ApplicationRecord
  belongs_to :game, optional: true, dependent: :destroy
end