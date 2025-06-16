FactoryBot.define do
  factory :default_board, aliases: [:game], class: 'Board' do
    columns { 5 }
    rows { 3 }
  end

  # traid :user

  factory :user_1, aliases: [:brian], class: 'User' do
    email { 'brian@me.com' }
    username { 'brian' }
    password { 'test@SomePwd' }
  end
  
  factory :user_2, aliases: [:ken], class: 'User' do
    email { 'ken@me.com' }
    username { 'ken' }
    password { 'test@SomePwd' }
  end

end