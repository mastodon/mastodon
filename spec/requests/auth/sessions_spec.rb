# frozen_string_literal: true

require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe 'Auth Sessions' do
  describe 'DELETE /auth/sign_out' do
    let(:user) { Fabricate(:user) }

    before { sign_in user }

    it 'clears the notice and password challenge after sign out' do
      post settings_otp_authentication_path, params: { form_challenge: { current_password: user.password } }
      expect(request.session[:challenge_passed_at]).to be_present

      delete destroy_user_session_path

      expect(flash[:notice]).to be_blank
      expect(request.session[:challenge_passed_at]).to be_blank
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'does not delete the redirect location with continue=true' do
      application = Fabricate(:application, scopes: 'read')
      get oauth_authorization_path(client_id: application.uid, response_type: 'code', redirect_uri: application.redirect_uri, scope: 'read')
      stored_location = request.session[:user_return_to]
      expect(stored_location).to be_present

      delete destroy_user_session_path, params: { continue: 'true' }

      expect(request.session[:user_return_to]).to eq(stored_location)
    end
  end

  describe 'POST /auth/sign_in' do
    context 'with invalid nested params' do
      # The rack-attack check has issues with the non-nested invalid param used here
      before { Rack::Attack.enabled = false }
      after { Rack::Attack.enabled = true }

      it 'gracefully handles invalid nested params' do
        post user_session_path(user: 'invalid')

        expect(response)
          .to have_http_status(400)
      end
    end

    context 'when using PAM authentication', if: ENV['PAM_ENABLED'] == 'true' do
      context 'when using a valid password' do
        before do
          post user_session_path, params: { user: { email: 'pam_user1', password: '123456' } }
        end

        it 'redirects to home and logs the user in' do
          expect(response).to redirect_to(root_path)
          expect(request.env['warden'].user).to be_instance_of(User)
        end
      end

      context 'when using an invalid password' do
        before do
          post user_session_path, params: { user: { email: 'pam_user1', password: 'WRONGPW' } }
        end

        it 'shows a login error and does not log the user in' do
          expect(flash[:alert]).to match(/#{failure_message_invalid_email}/i)
          expect(request.env['warden'].user).to be_nil
        end
      end

      context 'when using a valid email and existing user' do
        let!(:user) do
          account = Fabricate.build(:account, username: 'pam_user1', user: nil)
          account.save!(validate: false)
          Fabricate(:user, email: 'pam@example.com', password: nil, account: account, external: true)
        end

        before do
          post user_session_path, params: { user: { email: user.email, password: '123456' } }
        end

        it 'redirects to home and logs the user in' do
          expect(response).to redirect_to(root_path)
          expect(request.env['warden'].user).to eq(user)
        end
      end
    end

    context 'when using password authentication' do
      let(:user) { Fabricate(:user, email: 'foo@bar.com', password: 'abcdefgh') }

      context 'when using a valid password on a previously-used account with a new IP address' do
        subject { post user_session_path, params: { user: { email: user.email, password: user.password } }, headers: { 'REMOTE_ADDR' => current_ip } }

        let(:previous_ip) { '1.2.3.4' }
        let(:current_ip)  { '4.3.2.1' }

        before do
          Fabricate(:login_activity, user: user, ip: previous_ip)
          user.update(current_sign_in_at: 1.month.ago)
        end

        it 'logs the user in and sends suspicious email and redirects home', :inline_jobs do
          emails = capture_emails { subject }

          expect(response).to redirect_to(root_path)
          expect(request.env['warden'].user).to eq(user)
          expect(emails.size).to eq(1)
          expect(emails.first)
            .to have_attributes(
              to: contain_exactly(user.email),
              subject: eq(I18n.t('user_mailer.suspicious_sign_in.subject'))
            )
        end
      end

      context 'when using an invalid password' do
        before do
          post user_session_path, params: { user: { email: user.email, password: 'wrongpw' } }
        end

        it 'shows a login error and does not log the user in' do
          expect(flash[:alert]).to match(/#{failure_message_invalid_email}/i)
          expect(request.env['warden'].user).to be_nil
        end
      end

      context 'when using an unconfirmed account' do
        let(:accept_language) { 'fr' }

        before do
          user.update!(confirmed_at: nil)
          post user_session_path,
               params: { user: { email: user.email, password: user.password } },
               headers: { 'Accept-Language' => accept_language }
        end

        it 'redirects to home' do
          expect(response).to redirect_to(root_path)
        end
      end

      context "when logging in from the user's page" do
        before do
          allow(Rails.configuration.x).to receive(:single_user_mode).and_return(single_user_mode)
          get new_user_session_path, headers: { 'Referer' => short_account_url(username: user.account) }
          post user_session_path, params: { user: { email: user.email, password: user.password } }
        end

        context 'with single user mode' do
          let(:single_user_mode) { true }

          it 'redirects to home' do
            expect(response).to redirect_to(root_path)
          end
        end

        context 'with non-single user mode' do
          let(:single_user_mode) { false }

          it "redirects back to the user's page" do
            expect(response).to redirect_to(short_account_path(username: user.account))
          end
        end
      end
    end

    context 'with OTP enabled as second factor' do
      let!(:user) { Fabricate(:user, email: 'x@y.com', password: 'abcdefgh', otp_required_for_login: true, otp_secret: User.generate_otp_secret) }

      before do
        post user_session_path, params: { user: { email: user.email, password: user.password } }
      end

      context 'when there is an unfinished log-in attempt to another 2FA-protected account' do
        let(:other_user) { Fabricate(:user, email: 'z@y.com', password: 'abcdefgh', otp_required_for_login: true, otp_secret: User.generate_otp_secret) }

        it 'starts a new two factor authentication attempt for the requested account' do
          post user_session_path, params: { user: { email: other_user.email, password: other_user.password } }
          post user_session_path, params: { user: { email: user.email, password: user.password } }

          expect(response.parsed_body)
            .to have_css('p.hint.authentication-hint', text: I18n.t('simple_form.hints.sessions.otp'))
          expect(request.session[:attempt_user_id]).to eq(user.id)
          expect(request.env['warden'].user).to be_nil
        end
      end

      context 'when repeatedly using an invalid TOTP code before using a valid code' do
        before do
          stub_const('Auth::SessionsController::MAX_2FA_ATTEMPTS_PER_HOUR', 2)
          # Travel to the beginning of an hour to avoid crossing rate-limit buckets
          travel_to '2023-12-20T10:00:00Z'
        end

        it 'does not log the user in, sets a flash message, and sends a suspicious sign in email', :inline_jobs do
          emails = capture_emails do
            expect { process_maximum_two_factor_attempts }
              .to change(user.login_activities.where(success: false), :count).by(1)

            post user_session_path, params: { user: { otp_attempt: user.current_otp } }
          end

          expect(request.env['warden'].user).to be_nil
          expect(flash[:alert]).to match I18n.t('users.rate_limited')
          expect(emails.size).to eq(1)
          expect(emails.first)
            .to have_attributes(
              to: contain_exactly(user.email),
              subject: eq(I18n.t('user_mailer.failed_2fa.subject'))
            )
        end

        def process_maximum_two_factor_attempts
          Auth::SessionsController::MAX_2FA_ATTEMPTS_PER_HOUR.times do
            post user_session_path, params: { user: { otp_attempt: '1234' } }
            expect(request.env['warden'].user).to be_nil
          end
        end
      end

      context 'when the server has a decryption error' do
        before do
          allow(user).to receive(:validate_and_consume_otp!).with(user.current_otp).and_raise(OpenSSL::Cipher::CipherError)
          allow(User).to receive(:find_by).with(id: user.id).and_return(user)

          post user_session_path, params: { user: { otp_attempt: user.current_otp } }
        end

        it 'shows a login error and does not log the user in' do
          expect(flash[:alert]).to match I18n.t('users.invalid_otp_token')
          expect(request.env['warden'].user).to be_nil
        end
      end

      context 'when using an invalid OTP' do
        before do
          post user_session_path, params: { user: { otp_attempt: 'wrongotp' } }
        end

        it 'shows a login error and does not log the user in' do
          expect(flash[:alert]).to match I18n.t('users.invalid_otp_token')
          expect(request.env['warden'].user).to be_nil
        end
      end
    end

    context 'with WebAuthn enabled as second factor' do
      let!(:user) { Fabricate(:user, email: 'x@y.com', password: 'abcdefgh') }
      let!(:webauthn_credential) do
        user.update(webauthn_id: WebAuthn.generate_user_id)
        public_key_credential = WebAuthn::Credential.from_create(fake_client.create)
        user.webauthn_credentials.create!(
          nickname: 'SecurityKeyNickname',
          external_id: public_key_credential.id,
          public_key: public_key_credential.public_key,
          sign_count: '1000'
        )
      end

      let(:domain) { "#{Rails.configuration.x.use_https ? 'https' : 'http'}://#{Rails.configuration.x.web_domain}" }
      let(:fake_client) { WebAuthn::FakeClient.new(domain) }
      let(:sign_count) { 1234 }

      context 'when using email and password' do
        before do
          post user_session_path, params: { user: { email: user.email, password: user.password } }
        end

        it 'renders webauthn authentication page' do
          expect(response.parsed_body)
            .to have_css('h3.title', text: I18n.t('simple_form.title.sessions.webauthn'))
        end
      end

      context 'when using upcase email and password' do
        before do
          post user_session_path, params: { user: { email: user.email.upcase, password: user.password } }
        end

        it 'renders webauthn authentication page' do
          expect(response.parsed_body)
            .to have_css('h3.title', text: I18n.t('simple_form.title.sessions.webauthn'))
        end
      end

      context 'when using a valid webauthn credential' do
        it 'instructs the browser to redirect to home, logs the user in, and updates the sign count' do
          post user_session_path, params: { user: { email: user.email, password: user.password } }
          get auth_sessions_security_key_options_path
          credential = fake_client.get(challenge: response.parsed_body[:challenge], sign_count: sign_count)

          post user_session_path, params: { user: { credential: credential } }

          expect(response.parsed_body[:redirect_path]).to eq(root_path)
          expect(request.env['warden'].user).to eq(user)
          expect(webauthn_credential.reload.sign_count).to eq(sign_count)
        end
      end
    end

    context 'when 2FA is disabled and inactive for long' do
      let!(:user) { Fabricate(:user, email: 'x@y.com', password: 'abcdefgh', current_sign_in_at: 7.months.ago) }

      before do
        allow(UserMailer).to receive(:sign_in_token).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later!: nil))
      end

      context 'when using an invalid password' do
        before do
          post user_session_path, params: { user: { email: user.email, password: 'wrongpw' } }
        end

        it 'shows a login error and does not log the user in' do
          expect(flash[:alert]).to match(/#{failure_message_invalid_email}/i)
          expect(request.env['warden'].user).to be_nil
        end
      end

      context 'when using an invalid sign in token' do
        before do
          post user_session_path, params: { user: { email: user.email, password: user.password } }
          post user_session_path, params: { user: { sign_in_token_attempt: 'wrongotp' } }
        end

        it 'shows a login error and does not log the user in' do
          expect(flash[:alert]).to match I18n.t('users.invalid_sign_in_token')
          expect(request.env['warden'].user).to be_nil
        end
      end
    end

    def failure_message_invalid_email
      I18n.t('devise.failure.invalid', authentication_keys: I18n.t('activerecord.attributes.user.email'))
    end
  end
end
