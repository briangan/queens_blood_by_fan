require 'rails_helper'
require 'helpers/users_spec_helper'

include UsersSpecHelper

RSpec.describe 'User', type: :system do
  # let(:user) { FactoryBot.create(:user) }
  let(:username) { (10 + rand(26)).to_s(36) + (100000000 + rand(100000000)).to_s(36) }

  before do
    driven_by(:rack_test)
  end

  it "allows user to sign up, log in, and log out" do
    visit root_path
    expect(page).to have_link("Login")
    click_link "Login"
    expect(page).to have_content("Log in")

    expect(page).to have_link("Sign up")
    click_link "Sign up"

    expect(page).to have_current_path(new_user_registration_path)

    email = "#{username}@example.com"
    user = sign_up_user(username, email, 'password1234')

    click_link "Logout"

    expect(page).to have_current_path(new_user_session_path)

    sign_in_user(email, 'password1234')
  end
end