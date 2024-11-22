# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::RegistrationsController do
  render_views

  shared_examples 'checks for enabled registrations' do |path|
    context 'when in single user mode and open for registration' do
      before do
        Setting.registrations_mode = 'open'
        allow(Rails.configuration.x).to receive(:single_user_mode).and_return(true)
      end

      it 'redirects to root' do
        Fabricate(:account)
        get path

        expect(response).to redirect_to '/'
        expect(Rails.configuration.x).to have_received(:single_user_mode)
      end
    end

    context 'when registrations closed and not in single user mode' do
      before do
        Setting.registrations_mode = 'none'
        allow(Rails.configuration.x).to receive(:single_user_mode).and_return(false)
      end

      it 'redirects to root' do
        get path

        expect(response).to redirect_to '/'
        expect(Rails.configuration.x).to have_received(:single_user_mode)
      end
    end
  end

  describe 'GET #edit' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in(Fabricate(:user))
      get :edit
    end

    it 'returns http success and cache headers' do
      expect(response)
        .to have_http_status(200)

      expect(response.headers['Cache-Control'])
        .to include('private, no-store')
    end
  end

  describe 'PUT #update' do
    let(:current_password) { 'current password' }
    let(:user) { Fabricate(:user, password: current_password) }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in(user, scope: :user)
    end

    it 'returns http success and cache headers' do
      put :update

      expect(response)
        .to have_http_status(200)
      expect(response.headers['Cache-Control'])
        .to include('private, no-store')
    end

    it 'can update the user email' do
      expect do
        put :update, params: {
          user: {
            email: 'newemail@example.com',
            current_password: current_password,
          },
        }
        expect(response).to redirect_to(edit_user_registration_path)
      end.to change { user.reload.unconfirmed_email }.to('newemail@example.com')
    end

    it 'requires the current password to update the email' do
      expect do
        put :update, params: {
          user: {
            email: 'newemail@example.com',
            current_password: 'something',
          },
        }
        expect(response).to have_http_status(200)
      end.to_not(change { user.reload.unconfirmed_email })
    end

    it 'can update the user password' do
      expect do
        put :update, params: {
          user: {
            password: 'new password',
            password_confirmation: 'new password',
            current_password: current_password,
          },
        }
        expect(response).to redirect_to(edit_user_registration_path)
      end.to(change { user.reload.encrypted_password })
    end

    it 'requires the password confirmation' do
      expect do
        put :update, params: {
          user: {
            password: 'new password',
            password_confirmation: 'something else',
            current_password: current_password,
          },
        }
        expect(response).to have_http_status(200)
      end.to_not(change { user.reload.encrypted_password })
    end

    it 'requires the current password to update the password' do
      expect do
        put :update, params: {
          user: {
            password: 'new password',
            password_confirmation: 'new password',
            current_password: 'something',
          },
        }
        expect(response).to have_http_status(200)
      end.to_not(change { user.reload.encrypted_password })
    end

    context 'when suspended' do
      let(:user) { Fabricate(:user, account_attributes: { username: 'test', suspended_at: Time.now.utc }) }

      it 'returns http forbidden' do
        put :update
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'GET #new' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'with open registrations' do
      it 'returns http success' do
        Setting.registrations_mode = 'open'
        get :new
        expect(response).to have_http_status(200)
      end
    end

    include_examples 'checks for enabled registrations', :new
  end

  describe 'POST #create' do
    let(:accept_language) { 'de' }

    before do
      session[:registration_form_time] = 5.seconds.ago

      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    around do |example|
      I18n.with_locale(I18n.locale) do
        example.run
      end
    end

    context 'when an accept language is present in headers' do
      subject do
        Setting.registrations_mode = 'open'
        request.headers['Accept-Language'] = accept_language
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } }
      end

      it 'redirects to setup and creates user' do
        subject

        expect(response)
          .to redirect_to auth_setup_path
        expect(User.find_by(email: 'test@example.com'))
          .to be_present
          .and have_attributes(locale: eq(accept_language))
      end
    end

    context 'when user has not agreed to terms of service' do
      subject do
        Setting.registrations_mode = 'open'
        request.headers['Accept-Language'] = accept_language
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'false' } }
      end

      it 'does not create user' do
        subject
        user = User.find_by(email: 'test@example.com')
        expect(user).to be_nil
      end
    end

    context 'when user has an email address requiring approval' do
      subject do
        request.headers['Accept-Language'] = accept_language
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } }
      end

      before do
        Setting.registrations_mode = 'open'
        Fabricate(:email_domain_block, allow_with_approval: true, domain: 'example.com')
      end

      it 'creates unapproved user and redirects to setup' do
        subject
        expect(response).to redirect_to auth_setup_path

        user = User.find_by(email: 'test@example.com')
        expect(user).to_not be_nil
        expect(user.locale).to eq(accept_language)
        expect(user.approved).to be(false)
      end
    end

    context 'when user has an email address requiring approval through a MX record' do
      subject do
        request.headers['Accept-Language'] = accept_language
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } }
      end

      before do
        Setting.registrations_mode = 'open'
        Fabricate(:email_domain_block, allow_with_approval: true, domain: 'mail.example.com')
        allow(User).to receive(:skip_mx_check?).and_return(false)
        configure_mx(domain: 'example.com', exchange: 'mail.example.com')
      end

      it 'creates unapproved user and redirects to setup' do
        subject
        expect(response).to redirect_to auth_setup_path

        user = User.find_by(email: 'test@example.com')
        expect(user).to_not be_nil
        expect(user.locale).to eq(accept_language)
        expect(user.approved).to be(false)
      end
    end

    context 'with Approval-based registrations without invite' do
      subject do
        Setting.registrations_mode = 'approved'
        request.headers['Accept-Language'] = accept_language
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } }
      end

      it 'redirects to setup and creates user' do
        subject

        expect(response)
          .to redirect_to auth_setup_path

        expect(User.find_by(email: 'test@example.com'))
          .to be_present
          .and have_attributes(
            locale: eq(accept_language),
            approved: be(false)
          )
      end
    end

    context 'with Approval-based registrations with expired invite' do
      subject do
        Setting.registrations_mode = 'approved'
        request.headers['Accept-Language'] = accept_language
        invite = Fabricate(:invite, max_uses: nil, expires_at: 1.hour.ago)
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', invite_code: invite.code, agreement: 'true' } }
      end

      it 'redirects to setup and creates user' do
        subject

        expect(response).to redirect_to auth_setup_path

        expect(User.find_by(email: 'test@example.com'))
          .to be_present
          .and have_attributes(
            locale: eq(accept_language),
            approved: be(false)
          )
      end
    end

    context 'with Approval-based registrations with valid invite and required invite text' do
      subject do
        inviter = Fabricate(:user, confirmed_at: 2.days.ago)
        Setting.registrations_mode = 'approved'
        Setting.require_invite_text = true
        request.headers['Accept-Language'] = accept_language
        invite = Fabricate(:invite, user: inviter, max_uses: nil, expires_at: 1.hour.from_now)
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', invite_code: invite.code, agreement: 'true' } }
      end

      it 'redirects to setup and creates user' do
        subject

        expect(response).to redirect_to auth_setup_path

        expect(User.find_by(email: 'test@example.com'))
          .to be_present
          .and have_attributes(
            locale: eq(accept_language),
            approved: be(true)
          )
      end
    end

    context 'with an already taken username' do
      subject do
        Setting.registrations_mode = 'open'
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } }
      end

      before do
        Fabricate(:account, username: 'test')
      end

      it 'responds with an error message about the username' do
        subject

        expect(response).to have_http_status(:success)
        expect(username_error_text).to eq(I18n.t('errors.messages.taken'))
      end

      def username_error_text
        response.parsed_body.css('.user_account_username .error').text
      end
    end

    include_examples 'checks for enabled registrations', :create
  end

  describe 'DELETE #destroy' do
    let(:user) { Fabricate(:user) }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in(user, scope: :user)
      delete :destroy
    end

    it 'returns http not found and keeps user' do
      expect(response)
        .to have_http_status(404)
      expect(User.find(user.id))
        .to_not be_nil
    end
  end
end
