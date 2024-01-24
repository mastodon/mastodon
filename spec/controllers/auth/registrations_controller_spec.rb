# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::RegistrationsController do
  render_views

  shared_examples 'checks for enabled registrations' do |path|
    it 'redirects if it is in single user mode while it is open for registration' do
      Fabricate(:account)
      Setting.registrations_mode = 'open'
      allow(Rails.configuration.x).to receive(:single_user_mode).and_return(true)

      get path

      expect(response).to redirect_to '/'
      expect(Rails.configuration.x).to have_received(:single_user_mode)
    end

    it 'redirects if it is not open for registration while it is not in single user mode' do
      Setting.registrations_mode = 'none'
      allow(Rails.configuration.x).to receive(:single_user_mode).and_return(false)

      get path

      expect(response).to redirect_to '/'
      expect(Rails.configuration.x).to have_received(:single_user_mode)
    end
  end

  describe 'GET #edit' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in(Fabricate(:user))
      get :edit
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns private cache control header' do
      expect(response.headers['Cache-Control']).to include('private, no-store')
    end
  end

  describe 'GET #update' do
    let(:user) { Fabricate(:user) }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in(user, scope: :user)
      post :update
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns private cache control headers' do
      expect(response.headers['Cache-Control']).to include('private, no-store')
    end

    context 'when suspended' do
      let(:user) { Fabricate(:user, account_attributes: { username: 'test', suspended_at: Time.now.utc }) }

      it 'returns http forbidden' do
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

        resolver = instance_double(Resolv::DNS, :timeouts= => nil)

        allow(resolver).to receive(:getresources)
          .with('example.com', Resolv::DNS::Resource::IN::MX)
          .and_return([instance_double(Resolv::DNS::Resource::MX, exchange: 'mail.example.com')])
        allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([])
        allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::AAAA).and_return([])
        allow(resolver).to receive(:getresources).with('mail.example.com', Resolv::DNS::Resource::IN::A).and_return([instance_double(Resolv::DNS::Resource::IN::A, address: '2.3.4.5')])
        allow(resolver).to receive(:getresources).with('mail.example.com', Resolv::DNS::Resource::IN::AAAA).and_return([instance_double(Resolv::DNS::Resource::IN::AAAA, address: 'fd00::2')])
        allow(Resolv::DNS).to receive(:open).and_yield(resolver)
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

    context 'with Approval-based registrations with expired invite' do
      subject do
        Setting.registrations_mode = 'approved'
        request.headers['Accept-Language'] = accept_language
        invite = Fabricate(:invite, max_uses: nil, expires_at: 1.hour.ago)
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', invite_code: invite.code, agreement: 'true' } }
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

    context 'with Approval-based registrations with valid invite and required invite text' do
      subject do
        inviter = Fabricate(:user, confirmed_at: 2.days.ago)
        Setting.registrations_mode = 'approved'
        Setting.require_invite_text = true
        request.headers['Accept-Language'] = accept_language
        invite = Fabricate(:invite, user: inviter, max_uses: nil, expires_at: 1.hour.from_now)
        post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', invite_code: invite.code, agreement: 'true' } }
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
        Nokogiri::Slop(response.body).css('.user_account_username .error').text
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

    it 'returns http not found' do
      expect(response).to have_http_status(404)
    end

    it 'does not delete user' do
      expect(User.find(user.id)).to_not be_nil
    end
  end
end
