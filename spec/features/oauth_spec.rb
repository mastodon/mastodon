# frozen_string_literal: true

require 'rails_helper'

describe 'Using OAuth from an external app' do
  let(:client_app) { Doorkeeper::Application.create!(name: 'test', redirect_uri: 'http://localhost/', scopes: 'read') }

  context 'when the user is already logged in' do
    let!(:user) { Fabricate(:user) }

    before do
      sign_in user, scope: :user
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
      user.confirm!
      user.approve!
    end

    it 'when accepting the authorization request' do
      params = { client_id: client_app.uid, response_type: 'code', redirect_uri: client_app.redirect_uri, scope: 'read' }
      visit "/oauth/authorize?#{params.to_query}"

      # It presents the user with a log-in page
      expect(page).to have_content(I18n.t('auth.login'))

      # Failing to log-in presents the form again
      fill_in 'user_email', with: email
      fill_in 'user_password', with: 'wrong password'
      click_on I18n.t('auth.login')
      expect(page).to have_content(I18n.t('auth.login'))

      # Logging in redirects to an authorization page
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      click_on I18n.t('auth.login')
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
      fill_in 'user_email', with: email
      fill_in 'user_password', with: 'wrong password'
      click_on I18n.t('auth.login')
      expect(page).to have_content(I18n.t('auth.login'))

      # Logging in redirects to an authorization page
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      click_on I18n.t('auth.login')
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
        fill_in 'user_email', with: email
        fill_in 'user_password', with: 'wrong password'
        click_on I18n.t('auth.login')
        expect(page).to have_content(I18n.t('auth.login'))

        # Logging in redirects to a two-factor authentication page
        fill_in 'user_email', with: email
        fill_in 'user_password', with: password
        click_on I18n.t('auth.login')
        expect(page).to have_content(I18n.t('simple_form.hints.sessions.otp'))

        # Filling in an incorrect two-factor authentication code presents the form again
        fill_in 'user_otp_attempt', with: 'wrong'
        click_on I18n.t('auth.login')
        expect(page).to have_content(I18n.t('simple_form.hints.sessions.otp'))

        # Filling in the correct TOTP code redirects to an app authorization page
        fill_in 'user_otp_attempt', with: user.current_otp
        click_on I18n.t('auth.login')
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
        fill_in 'user_email', with: email
        fill_in 'user_password', with: 'wrong password'
        click_on I18n.t('auth.login')
        expect(page).to have_content(I18n.t('auth.login'))

        # Logging in redirects to a two-factor authentication page
        fill_in 'user_email', with: email
        fill_in 'user_password', with: password
        click_on I18n.t('auth.login')
        expect(page).to have_content(I18n.t('simple_form.hints.sessions.otp'))

        # Filling in an incorrect two-factor authentication code presents the form again
        fill_in 'user_otp_attempt', with: 'wrong'
        click_on I18n.t('auth.login')
        expect(page).to have_content(I18n.t('simple_form.hints.sessions.otp'))

        # Filling in the correct TOTP code redirects to an app authorization page
        fill_in 'user_otp_attempt', with: user.current_otp
        click_on I18n.t('auth.login')
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
end
