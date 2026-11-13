# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Registrations' do
  shared_examples 'registration mode based responses' do
    context 'when in single user mode and open for registration' do
      before do
        Setting.registrations_mode = 'open'
        allow(Rails.configuration.x).to receive(:single_user_mode).and_return(true)
      end

      it 'redirects to sign-in' do
        Fabricate(:account)
        subject

        expect(response).to redirect_to(new_user_session_path)
        expect(Rails.configuration.x).to have_received(:single_user_mode)
      end
    end

    context 'when registrations closed and not in single user mode' do
      before do
        Setting.registrations_mode = 'none'
        allow(Rails.configuration.x).to receive(:single_user_mode).and_return(false)
      end

      it 'redirects to sign-in' do
        subject

        expect(response).to redirect_to(new_user_session_path)
        expect(Rails.configuration.x).to have_received(:single_user_mode)
      end
    end
  end

  describe 'GET /auth/sign_up' do
    subject { get new_user_registration_path }

    it_behaves_like 'registration mode based responses'
  end

  describe 'PUT #update' do
    let(:current_password) { 'current password' }
    let(:user) { Fabricate(:user, password: current_password) }

    before { sign_in(user) }

    it 'requires the current password to update the email' do
      expect do
        put user_registration_path, params: {
          user: {
            email: 'newemail@example.com',
            current_password: 'something',
          },
        }
      end.to_not(change { user.reload.unconfirmed_email })

      expect(response).to have_http_status(422)
      expect(response.headers['Cache-Control'])
        .to include('private, no-store')
    end

    it 'requires the password confirmation' do
      expect do
        put user_registration_path, params: {
          user: {
            password: 'new password',
            password_confirmation: 'something else',
            current_password: current_password,
          },
        }
      end.to_not(change { user.reload.encrypted_password })

      expect(response).to have_http_status(422)
    end

    it 'requires the current password to update the password' do
      expect do
        put user_registration_path, params: {
          user: {
            password: 'new password',
            password_confirmation: 'new password',
            current_password: 'something',
          },
        }
      end.to_not(change { user.reload.encrypted_password })

      expect(response).to have_http_status(422)
    end

    context 'when suspended' do
      let(:user) { Fabricate(:user, account_attributes: { username: 'test', suspended_at: Time.now.utc }) }

      it 'returns http forbidden' do
        put user_registration_path

        expect(response).to have_http_status(403)
      end
    end

    context 'when deleted' do
      let(:user) { Fabricate(:user, account_attributes: { username: 'test', requested_deletion_at: Time.now.utc }) }

      it 'returns http forbidden' do
        put user_registration_path

        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'POST #create' do
    subject { post user_registration_path }

    let(:accept_language) { 'de' }

    around do |example|
      I18n.with_locale(I18n.locale) do
        example.run
      end
    end

    it_behaves_like 'registration mode based responses'

    context 'when user has not agreed to terms of service' do
      subject do
        post user_registration_path,
             params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'false' } },
             headers: { 'Accept-Language' => accept_language }
      end

      before { Setting.registrations_mode = 'open' }

      it 'does not create user' do
        subject

        user = User.find_by(email: 'test@example.com')
        expect(user).to be_nil
      end
    end

    context 'when user has an email address requiring approval' do
      subject do
        post user_registration_path,
             params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } },
             headers: { 'Accept-Language' => accept_language }
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
        post user_registration_path,
             params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } },
             headers: { 'Accept-Language' => accept_language }
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

    context 'with an already taken username' do
      subject do
        post user_registration_path,
             params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678', agreement: 'true' } }
      end

      before do
        Fabricate(:account, username: 'test')
        Setting.registrations_mode = 'open'
      end

      it 'responds with an error message about the username' do
        subject

        expect(response).to have_http_status(422)
        expect(username_error_text).to eq(I18n.t('errors.messages.taken'))
      end

      def username_error_text
        response.parsed_body.css('.user_account_username .error').text
      end
    end

    context 'with an invalid date of birth' do
      subject do
        post user_registration_path, params: {
          user: {
            :account_attributes => { username: 'test' },
            :email => 'test@example.com',
            :password => '12345678',
            :password_confirmation => '12345678',
            :agreement => 'true',
            'date_of_birth(1i)' => '2019',
            'date_of_birth(2i)' => '32',
            'date_of_birth(3i)' => '01',
          },
        }
      end

      before do
        Setting.registrations_mode = 'open'
        Setting.min_age = 16
      end

      it 'responds with an error message about the date of birth' do
        expect { subject }.to_not raise_error

        expect(response).to have_http_status(422)
        expect(date_of_birth_error_text).to eq(I18n.t('errors.messages.invalid'))
        expect(User.find_by(email: 'test@example.com')).to be_nil
      end

      def date_of_birth_error_text
        response.parsed_body.css('.user_date_of_birth .error').text
      end
    end
  end

  describe 'DELETE /auth' do
    let(:user) { Fabricate(:user) }

    before { sign_in user }

    it 'returns http not found and keeps user' do
      delete user_registration_path

      expect(response)
        .to have_http_status(404)
      expect(User.find(user.id))
        .to_not be_nil
    end
  end
end
