# frozen_string_literal: true

require 'rails_helper'

describe 'Using OAuth from an external app', :js, :streaming do
  let(:client_app) { Doorkeeper::Application.create!(name: 'test', redirect_uri: about_url(host: Rails.application.config.x.local_domain), scopes: 'read') }

  context 'when the user is already logged in' do
    let!(:user) { Fabricate(:user) }

    before do
      visit new_user_session_path
      fill_in_auth_details(user.email, user.password)
    end

    it 'when accepting the authorization request' do
      params = { client_id: client_app.uid, response_type: 'code', redirect_uri: client_app.redirect_uri, scope: 'read' }
      visit "/oauth/authorize?#{params.to_query}"

      # It presents the user with an authorization page
      expect(page).to have_content(I18n.t('doorkeeper.authorizations.buttons.authorize'))

      # Upon authorizing, it redirects to the apps' callback URL
      click_on I18n.t('doorkeeper.authorizations.buttons.authorize')
      expect(page).to have_current_path(/\A#{client_app.redirect_uri}/, url: true)

      # It grants the app access to the account
      expect(Doorkeeper::AccessGrant.exists?(application: client_app, resource_owner_id: user.id)).to be true
    end

    it 'when rejecting the authorization request' do
      params = { client_id: client_app.uid, response_type: 'code', redirect_uri: client_app.redirect_uri, scope: 'read' }
      visit "/oauth/authorize?#{params.to_query}"

      # It presents the user with an authorization page
      expect(page).to have_content(I18n.t('doorkeeper.authorizations.buttons.deny'))

      # Upon denying, it redirects to the apps' callback URL
      click_on I18n.t('doorkeeper.authorizations.buttons.deny')
      expect(page).to have_current_path(/\A#{client_app.redirect_uri}/, url: true)

      # It does not grant the app access to the account
      expect(Doorkeeper::AccessGrant.exists?(application: client_app, resource_owner_id: user.id)).to be false
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
      params = { client_id: client_app.uid, response_type: 'code', redirect_uri: client_app.redirect_uri, scope: 'read' }
      visit "/oauth/authorize?#{params.to_query}"

      # It presents the user with a log-in page
      expect(page).to have_content(I18n.t('auth.login'))

      # Failing to log-in presents the form again
      fill_in_auth_details(email, 'wrong password')
      expect(page).to have_content(I18n.t('auth.login'))

      # Logging in redirects to an authorization page
      fill_in_auth_details(email, password)
      expect(page).to have_content(I18n.t('doorkeeper.authorizations.buttons.authorize'))

      # Upon authorizing, it redirects to the apps' callback URL
      click_on I18n.t('doorkeeper.authorizations.buttons.authorize')
      expect(page).to have_current_path(/\A#{client_app.redirect_uri}/, url: true)

      # It grants the app access to the account
      expect(Doorkeeper::AccessGrant.exists?(application: client_app, resource_owner_id: user.id)).to be true
    end

    it 'when rejecting the authorization request' do
      params = { client_id: client_app.uid, response_type: 'code', redirect_uri: client_app.redirect_uri, scope: 'read' }
      visit "/oauth/authorize?#{params.to_query}"

      # It presents the user with a log-in page
      expect(page).to have_content(I18n.t('auth.login'))

      # Failing to log-in presents the form again
      fill_in_auth_details(email, 'wrong password')
      expect(page).to have_content(I18n.t('auth.login'))

      # Logging in redirects to an authorization page
      fill_in_auth_details(email, password)
      expect(page).to have_content(I18n.t('doorkeeper.authorizations.buttons.authorize'))

      # Upon denying, it redirects to the apps' callback URL
      click_on I18n.t('doorkeeper.authorizations.buttons.deny')
      expect(page).to have_current_path(/\A#{client_app.redirect_uri}/, url: true)

      # It does not grant the app access to the account
      expect(Doorkeeper::AccessGrant.exists?(application: client_app, resource_owner_id: user.id)).to be false
    end

    context 'when the user has set up TOTP' do
      let(:user) { Fabricate(:user, email: email, password: password, otp_required_for_login: true, otp_secret: User.generate_otp_secret(32)) }

      it 'when accepting the authorization request' do
        params = { client_id: client_app.uid, response_type: 'code', redirect_uri: client_app.redirect_uri, scope: 'read' }
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
        expect(page).to have_content(I18n.t('doorkeeper.authorizations.buttons.authorize'))

        # Upon authorizing, it redirects to the apps' callback URL
        click_on I18n.t('doorkeeper.authorizations.buttons.authorize')
        expect(page).to have_current_path(/\A#{client_app.redirect_uri}/, url: true)

        # It grants the app access to the account
        expect(Doorkeeper::AccessGrant.exists?(application: client_app, resource_owner_id: user.id)).to be true
      end

      it 'when rejecting the authorization request' do
        params = { client_id: client_app.uid, response_type: 'code', redirect_uri: client_app.redirect_uri, scope: 'read' }
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
        expect(page).to have_content(I18n.t('doorkeeper.authorizations.buttons.authorize'))

        # Upon denying, it redirects to the apps' callback URL
        click_on I18n.t('doorkeeper.authorizations.buttons.deny')
        expect(page).to have_current_path(/\A#{client_app.redirect_uri}/, url: true)

        # It does not grant the app access to the account
        expect(Doorkeeper::AccessGrant.exists?(application: client_app, resource_owner_id: user.id)).to be false
      end
    end
    # TODO: external auth
  end

  private

  def fill_in_auth_details(email, password)
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_on I18n.t('auth.login')
  end

  def fill_in_otp_details(value)
    fill_in 'user_otp_attempt', with: value
    click_on I18n.t('auth.login')
  end
end
