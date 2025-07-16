FactoryBot.define do
  factory :default_board, aliases: [:game], class: 'Board' do
    columns { 5 }
    rows { 3 }
  end

end