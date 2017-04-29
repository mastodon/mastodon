require "rails_helper"

feature "Log in" do
  scenario "A valid email and password user is able to log in" do
    email = "test@example.com"
    password = "password"
    Fabricate(:user, email: email, password: password)

    visit new_user_session_path
    fill_in "user_email", with: email
    fill_in "user_password", with: password
    click_on "Log in"

    expect(page).to have_css "div.app-holder[data-react-class=Mastodon]"
  end
end
