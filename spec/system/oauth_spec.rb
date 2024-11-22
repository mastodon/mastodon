# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Using OAuth from an external app' do
  include ProfileStories

  subject { visit "/oauth/authorize?#{params.to_query}" }

  let(:client_app) { Doorkeeper::Application.create!(name: 'test', redirect_uri: about_url(host: Rails.application.config.x.local_domain), scopes: 'read') }
  let(:params) do
    { client_id: client_app.uid, response_type: 'code', redirect_uri: client_app.redirect_uri, scope: 'read' }
  end

  context 'when the user is already logged in' do
    let!(:user) { Fabricate(:user) }

    before do
      visit new_user_session_path
      fill_in_auth_details(user.email, user.password)
    end

    it 'when accepting the authorization request' do
      subject

      # It presents the user with an authorization page
      expect(page).to have_content(oauth_authorize_text)

      # It grants the app access to the account
      expect { click_on oauth_authorize_text }
        .to change { user_has_grant_with_client_app? }.to(true)

      # Upon authorizing, it redirects to the apps' callback URL
      expect(page).to redirect_to_callback_url
    end

    it 'when rejecting the authorization request' do
      subject

      # It presents the user with an authorization page
      expect(page).to have_content(oauth_deny_text)

      # It does not grant the app access to the account
      expect { click_on oauth_deny_text }
        .to_not change { user_has_grant_with_client_app? }.from(false)

      # Upon denying, it redirects to the apps' callback URL
      expect(page).to redirect_to_callback_url
    end

    # The tests in this context ensures that requests without PKCE parameters
    # still work; In the future we likely want to force usage of PKCE for
    # security reasons, as per:
    #
    # https://www.ietf.org/archive/id/draft-ietf-oauth-security-topics-27.html#section-2.1.1-9
    context 'when not using PKCE' do
      it 'does not include the PKCE values in the hidden inputs' do
        subject

        code_challenge_inputs = all('.oauth-prompt input[name=code_challenge]', visible: false)
        code_challenge_method_inputs = all('.oauth-prompt input[name=code_challenge_method]', visible: false)

        expect(code_challenge_inputs).to_not be_empty
        expect(code_challenge_method_inputs).to_not be_empty

        (code_challenge_inputs.to_a + code_challenge_method_inputs.to_a).each do |input|
          expect(input.value).to be_nil
        end
      end
    end

    context 'when using PKCE' do
      let(:params) do
        { client_id: client_app.uid, response_type: 'code', redirect_uri: client_app.redirect_uri, scope: 'read', code_challenge_method: pkce_code_challenge_method, code_challenge: pkce_code_challenge }
      end
      let(:pkce_code_challenge) { SecureRandom.hex(32) }
      let(:pkce_code_challenge_method) { 'S256' }

      context 'when using S256 code challenge method' do
        it 'includes the PKCE values in the hidden inputs' do
          subject

          code_challenge_inputs = all('.oauth-prompt input[name=code_challenge]', visible: false)
          code_challenge_method_inputs = all('.oauth-prompt input[name=code_challenge_method]', visible: false)

          expect(code_challenge_inputs).to_not be_empty
          expect(code_challenge_method_inputs).to_not be_empty

          code_challenge_inputs.each do |input|
            expect(input.value).to eq pkce_code_challenge
          end
          code_challenge_method_inputs.each do |input|
            expect(input.value).to eq pkce_code_challenge_method
          end
        end
      end

      context 'when using plain code challenge method' do
        let(:pkce_code_challenge_method) { 'plain' }

        it 'does not include the PKCE values in the response' do
          subject

          expect(page).to have_no_css('.oauth-prompt input[name=code_challenge]')
          expect(page).to have_no_css('.oauth-prompt input[name=code_challenge_method]')
        end

        it 'does not include the authorize button' do
          subject

          expect(page).to have_no_css('.oauth-prompt button[type="submit"]')
        end

        it 'includes an error message' do
          subject

          within '.form-container .flash-message' do
            # FIXME: Replace with doorkeeper.errors.messages.invalid_code_challenge_method.one for Doorkeeper > 5.8.0
            # see: https://github.com/doorkeeper-gem/doorkeeper/pull/1747
            expect(page).to have_content(I18n.t('doorkeeper.errors.messages.invalid_code_challenge_method'))
          end
        end
      end
    end
  end

  context 'when the user is not already logged in' do
    let(:email)    { 'test@example.com' }
    let(:password) { 'testpassword' }
    let(:user)     { Fabricate(:user, email: email, password: password) }

    before do
      user.mark_email_as_confirmed!
      user.approve!
    end

    it 'when accepting the authorization request' do
      visit "/oauth/authorize?#{params.to_query}"

      # It presents the user with a log-in page
      expect(page).to have_content(I18n.t('auth.login'))

      # Failing to log-in presents the form again
      fill_in_auth_details(email, 'wrong password')
      expect(page).to have_content(I18n.t('auth.login'))

      # Logging in redirects to an authorization page
      fill_in_auth_details(email, password)
      expect(page).to have_content(oauth_authorize_text)

      # It grants the app access to the account
      expect { click_on oauth_authorize_text }
        .to change { user_has_grant_with_client_app? }.to(true)

      # Upon authorizing, it redirects to the apps' callback URL
      expect(page).to redirect_to_callback_url
    end

    it 'when rejecting the authorization request' do
      visit "/oauth/authorize?#{params.to_query}"

      # It presents the user with a log-in page
      expect(page).to have_content(I18n.t('auth.login'))

      # Failing to log-in presents the form again
      fill_in_auth_details(email, 'wrong password')
      expect(page).to have_content(I18n.t('auth.login'))

      # Logging in redirects to an authorization page
      fill_in_auth_details(email, password)
      expect(page).to have_content(oauth_authorize_text)

      # It does not grant the app access to the account
      expect { click_on oauth_deny_text }
        .to_not change { user_has_grant_with_client_app? }.from(false)

      # Upon denying, it redirects to the apps' callback URL
      expect(page).to redirect_to_callback_url
    end

    context 'when the user has set up TOTP' do
      let(:user) { Fabricate(:user, email: email, password: password, otp_required_for_login: true, otp_secret: User.generate_otp_secret) }

      it 'when accepting the authorization request' do
        visit "/oauth/authorize?#{params.to_query}"

        # It presents the user with a log-in page
        expect(page).to have_content(I18n.t('auth.login'))

        # Failing to log-in presents the form again
        fill_in_auth_details(email, 'wrong password')
        expect(page).to have_content(I18n.t('auth.login'))

        # Logging in redirects to a two-factor authentication page
        fill_in_auth_details(email, password)
        expect(page).to have_content(I18n.t('simple_form.hints.sessions.otp'))

        # Filling in an incorrect two-factor authentication code presents the form again
        fill_in_otp_details('wrong')
        expect(page).to have_content(I18n.t('simple_form.hints.sessions.otp'))

        # Filling in the correct TOTP code redirects to an app authorization page
        fill_in_otp_details(user.current_otp)
        expect(page).to have_content(oauth_authorize_text)

        # It grants the app access to the account
        expect { click_on oauth_authorize_text }
          .to change { user_has_grant_with_client_app? }.to(true)

        # Upon authorizing, it redirects to the apps' callback URL
        expect(page).to redirect_to_callback_url
      end

      it 'when rejecting the authorization request' do
        visit "/oauth/authorize?#{params.to_query}"

        # It presents the user with a log-in page
        expect(page).to have_content(I18n.t('auth.login'))

        # Failing to log-in presents the form again
        fill_in_auth_details(email, 'wrong password')
        expect(page).to have_content(I18n.t('auth.login'))

        # Logging in redirects to a two-factor authentication page
        fill_in_auth_details(email, password)
        expect(page).to have_content(I18n.t('simple_form.hints.sessions.otp'))

        # Filling in an incorrect two-factor authentication code presents the form again
        fill_in_otp_details('wrong')
        expect(page).to have_content(I18n.t('simple_form.hints.sessions.otp'))

        # Filling in the correct TOTP code redirects to an app authorization page
        fill_in_otp_details(user.current_otp)
        expect(page).to have_content(oauth_authorize_text)

        # It does not grant the app access to the account
        expect { click_on oauth_deny_text }
          .to_not change { user_has_grant_with_client_app? }.from(false)

        # Upon denying, it redirects to the apps' callback URL
        expect(page).to redirect_to_callback_url
      end
    end
    # TODO: external auth
  end

  private

  def fill_in_otp_details(value)
    fill_in 'user_otp_attempt', with: value
    click_on I18n.t('auth.login')
  end

  def oauth_authorize_text
    I18n.t('doorkeeper.authorizations.buttons.authorize')
  end

  def oauth_deny_text
    I18n.t('doorkeeper.authorizations.buttons.deny')
  end

  def redirect_to_callback_url
    have_current_path(/\A#{client_app.redirect_uri}/, url: true)
  end

  def user_has_grant_with_client_app?
    Doorkeeper::AccessGrant
      .exists?(
        application: client_app,
        resource_owner_id: user.id
      )
  end
end
