require "rails_helper"

feature "Log in" do
  given(:email)        { "test@examle.com" }
  given(:password)     { "password" }
  given(:confirmed_at) { Time.zone.now }

  background do
    Fabricate(:user, email: email, password: password, confirmed_at: confirmed_at)
    visit new_user_session_path
  end

  subject { page }

  scenario "A valid email and password user is able to log in" do
    fill_in "user_email", with: email
    fill_in "user_password", with: password
    click_on I18n.t('auth.login')

    is_expected.to have_css("div.app-holder")
  end

  scenario "A invalid email and password user is not able to log in" do
    fill_in "user_email", with: "invalid_email"
    fill_in "user_password", with: "invalid_password"
    click_on I18n.t('auth.login')

    is_expected.to have_css(".flash-message", text: failure_message("invalid"))
  end

  context do
    given(:confirmed_at) { nil }

    scenario "A unconfirmed user is not able to log in" do
      fill_in "user_email", with: email
      fill_in "user_password", with: password
      click_on I18n.t('auth.login')

      is_expected.to have_css(".flash-message", text: failure_message("unconfirmed"))
    end
  end

  def failure_message(message)
    keys = User.authentication_keys.map { |key| User.human_attribute_name(key) }
    I18n.t("devise.failure.#{message}", authentication_keys: keys.join("support.array.words_connector"))
  end
end
