require "rails_helper"

feature "Log in" do
  given(:email)    { "test@examle.com" }
  given(:password) { "password" }

  background do
    Fabricate(:user, email: email, password: password)
  end

  scenario "A valid email and password user is able to log in" do
    visit new_user_session_path
    fill_in "user_email", with: email
    fill_in "user_password", with: password
    click_on "Log in"

    expect(page).to have_css "div.app-holder"
  end
end
