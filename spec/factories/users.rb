FactoryBot.define do

  factory :user_1, aliases:[:brian], class:'User' do
    email { 'brian@me.com' } 
    username { 'brian' }
    rank { 0 }
    rating { 0.0 }
    before(:create) do |user|
      user.password = 'test1234'
    end
  end

  factory :user_2, aliases:[:ken], class:'User' do
    email { 'ken@me.com' } 
    username { 'ken' }
    rank { 0 }
    rating { 0.0 }
    before(:create) do |user|
      user.password = 'test1234'
    end
  end
end
