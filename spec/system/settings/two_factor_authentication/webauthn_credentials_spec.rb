# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings TwoFactorAuthentication WebauthnCredentials', :js, :streaming do
  let(:user) { Fabricate :user, otp_required_for_login: true, otp_secret: User.generate_otp_secret }
  let(:credential_name) { 'Security Key Name' }

  before do
    page.driver.with_playwright_page do |playwright|
      playwright.context.credentials.install
    end

    sign_in(user)
  end

  describe 'Registering a security key' do
    it 'requires a nickname and saves a new credential', :inline_jobs do
      visit new_settings_webauthn_credential_path

      click_on I18n.t('webauthn_credentials.add')
      expect(page)
        .to have_current_path(new_settings_webauthn_credential_path)

      fill_in 'new_webauthn_credential_nickname', with: credential_name
      expect { create_credential }
        .to change(user.webauthn_credentials, :count).by(1)
        .and send_email(subject: I18n.t('devise.mailer.webauthn_enabled.subject'))

      expect(user.webauthn_credentials.pluck(:nickname))
        .to contain_exactly(credential_name)
    end

    def create_credential
      click_on I18n.t('webauthn_credentials.add')
      expect(page)
        .to have_text(I18n.t('webauthn_credentials.create.success'))
    end
  end

  describe 'Authenticating with a security key' do
    it 'authenticates using the security key' do
      visit new_settings_webauthn_credential_path
      fill_in 'new_webauthn_credential_nickname', with: credential_name
      click_on I18n.t('webauthn_credentials.add')
      expect(page)
        .to have_text(I18n.t('webauthn_credentials.create.success'))

      visit settings_path
      within('.sidebar') { click_on 'Logout' }

      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      click_on I18n.t('auth.login')

      expect(page)
        .to have_css('#webauthn-form:not(.hidden)')

      click_on I18n.t('auth.use_security_key')

      expect(page)
        .to have_current_path(settings_profile_path)
    end
  end
end
