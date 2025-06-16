require 'rails_helper'

describe Card, type: :feature do

  context 'Managing Cards' do
    it 'Update Card, Tile Selection, and Abilities' do
      card = create(:basic_card)
      visit edit_card_path(card)
      fill_in 'Name', with: 'Security Officer'
      fill_in 'Card number', with: '2'
      fill_in 'Prawn rank', with: '2'
      fill_in 'Power', with: '3'
      click_button 'Update Card'
      expect(page).to have_content 'Card was successfully updated.'
      expect(page).to have_content 'Security Officer'
      expect(page).to have_content '2'
      expect(page).to have_content '2'
      expect(page).to have_content '3'
    end
  end

  private 

  
end