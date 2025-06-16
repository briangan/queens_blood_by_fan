##
# Data of a board spot which can be empty or placed with a card.
class BoardTile < ApplicationRecord
  has_paper_trail on: [:update]

  belongs_to :board
  belongs_to :claiming_user, class_name: 'User', foreign_key: 'claming_user_id', optional: true
end