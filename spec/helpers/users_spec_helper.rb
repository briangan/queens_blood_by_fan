module UsersSpecHelper
  
  # Using the Sign Up form to create users.
  # @return <User>
  def sign_up_user(username, email, password = 'password1234')
    fill_in "Username", with: username
    fill_in "Email", with: email
    fill_in 'user[password]', with: password
    fill_in "user[password_confirmation]", with: password
    click_button "Sign up"

    expect(page).to have_content("You have signed up successfully.")
    user = User.find_by(username: username)
    expect(user).not_to be_nil
    user
  end

  def sign_in_user(email, password = 'password1234')
    fill_in "Email", with: email
    fill_in "user[password]", with: password
    click_button "Log in"
    expect(page).to have_content("Signed in successfully.")
  end
end