# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::RegistrationsController, type: :controller do
  render_views

  shared_examples 'checks for enabled registrations' do |path|
    around do |example|
      registrations_mode = Setting.registrations_mode
      example.run
      Setting.registrations_mode = registrations_mode
    end

    it 'redirects if it is in single user mode while it is open for registration' do
      Fabricate(:account)
      Setting.registrations_mode = 'open'
      expect(Rails.configuration.x).to receive(:single_user_mode).and_return(true)

      get path

      expect(response).to redirect_to '/'
    end

    it 'redirects if it is not open for registration while it is not in single user mode' do
      Setting.registrations_mode = 'none'
      expect(Rails.configuration.x).to receive(:single_user_mode).and_return(false)

      get path

      expect(response).to redirect_to '/'
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in(Fabricate(:user))
      get :edit
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #update' do
    it 'returns http success' do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in(Fabricate(:user), scope: :user)
      post :update
      expect(response).to have_http_status(200)
    end

    context 'when suspended' do
      it 'returns http forbidden' do
        request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in(Fabricate(:user, account_attributes: { username: 'test', suspended_at: Time.now.utc }), scope: :user)
        post :update
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'GET #new' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context do
      around do |example|
        registrations_mode = Setting.registrations_mode
        example.run
        Setting.registrations_mode = registrations_mode
      end

      it 'returns http success' do
        Setting.registrations_mode = 'open'
        get :new
        expect(response).to have_http_status(200)
      end
    end

    include_examples 'checks for enabled registrations', :new
  end

  describe 'POST #create' do
    let(:accept_language) { Rails.application.config.i18n.available_locales.sample.to_s }

    before do
      session[:registration_form_time] = 5.seconds.ago
    end

    around do |example|
      current_locale = I18n.locale
      example.run
      I18n.locale = current_locale
    end

    before { request.env['devise.mapping'] = Devise.mappings[:user] }

    context do
      subject do
        Setting.registrations_mode = 'open'
        request.headers['Accept-Language'] = accept_language
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } }
      end

      around do |example|
        registrations_mode = Setting.registrations_mode
        example.run
        Setting.registrations_mode = registrations_mode
      end

      it 'redirects to setup' do
        subject
        expect(response).to redirect_to auth_setup_path
      end

      it 'creates user' do
        subject
        user = User.find_by(email: 'test@example.com')
        expect(user).to_not be_nil
        expect(user.locale).to eq(accept_language)
      end
    end

    context 'when user has not agreed to terms of service' do
      subject do
        Setting.registrations_mode = 'open'
        request.headers['Accept-Language'] = accept_language
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'false' } }
      end

      around do |example|
        registrations_mode = Setting.registrations_mode
        example.run
        Setting.registrations_mode = registrations_mode
      end

      it 'does not create user' do
        subject
        user = User.find_by(email: 'test@example.com')
        expect(user).to be_nil
      end
    end

    context 'approval-based registrations without invite' do
      subject do
        Setting.registrations_mode = 'approved'
        request.headers['Accept-Language'] = accept_language
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } }
      end

      around do |example|
        registrations_mode = Setting.registrations_mode
        example.run
        Setting.registrations_mode = registrations_mode
      end

      it 'redirects to setup' do
        subject
        expect(response).to redirect_to auth_setup_path
      end

      it 'creates user' do
        subject
        user = User.find_by(email: 'test@example.com')
        expect(user).to_not be_nil
        expect(user.locale).to eq(accept_language)
        expect(user.approved).to be(false)
      end
    end

    context 'approval-based registrations with expired invite' do
      subject do
        Setting.registrations_mode = 'approved'
        request.headers['Accept-Language'] = accept_language
        invite = Fabricate(:invite, max_uses: nil, expires_at: 1.hour.ago)
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', invite_code: invite.code, agreement: 'true' } }
      end

      around do |example|
        registrations_mode = Setting.registrations_mode
        example.run
        Setting.registrations_mode = registrations_mode
      end

      it 'redirects to setup' do
        subject
        expect(response).to redirect_to auth_setup_path
      end

      it 'creates user' do
        subject
        user = User.find_by(email: 'test@example.com')
        expect(user).to_not be_nil
        expect(user.locale).to eq(accept_language)
        expect(user.approved).to be(false)
      end
    end

    context 'approval-based registrations with valid invite and required invite text' do
      subject do
        inviter = Fabricate(:user, confirmed_at: 2.days.ago)
        Setting.registrations_mode = 'approved'
        Setting.require_invite_text = true
        request.headers['Accept-Language'] = accept_language
        invite = Fabricate(:invite, user: inviter, max_uses: nil, expires_at: 1.hour.from_now)
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', invite_code: invite.code, agreement: 'true' } }
      end

      around do |example|
        registrations_mode = Setting.registrations_mode
        require_invite_text = Setting.require_invite_text
        example.run
        Setting.require_invite_text = require_invite_text
        Setting.registrations_mode = registrations_mode
      end

      it 'redirects to setup' do
        subject
        expect(response).to redirect_to auth_setup_path
      end

      it 'creates user' do
        subject
        user = User.find_by(email: 'test@example.com')
        expect(user).to_not be_nil
        expect(user.locale).to eq(accept_language)
        expect(user.approved).to be(true)
      end
    end

    it 'does nothing if user already exists' do
      Fabricate(:account, username: 'test')
      subject
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

    it 'returns http not found' do
      expect(response).to have_http_status(404)
    end

    it 'does not delete user' do
      expect(User.find(user.id)).to_not be_nil
    end
  end
end
