FactoryBot.define do
  trait :standard_category do
    category { 'Standard' }
  end
  trait :legendary_category do
    category { 'Legendary' }
  end
  trait :normal_type do 
    type { 'Card' }
  end
  trait :replacement_type do
    type { 'ReplacementCard' }
  end

  factory :basic_card, aliases: [:security_officer_card], class:'Card' do
    name { 'Security Officer' }
    card_number { '1' }
    prawn { 1 }
    power { 1 }
  end

  factory :card_with_enhance_abilitiy, class:'Card' do
    name { 'Security Officer' }
    card_number { '1' }
    prawn { 1 }
    power { 1 }
  end

end