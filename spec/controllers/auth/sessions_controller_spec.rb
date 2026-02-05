# frozen_string_literal: true

require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe Auth::SessionsController do
  render_views

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { Fabricate(:user) }

    context 'with a regular user' do
      it 'redirects to home after sign out' do
        sign_in(user, scope: :user)
        delete :destroy

        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not delete redirect location with continue=true' do
        sign_in(user, scope: :user)
        controller.store_location_for(:user, '/authorize')
        delete :destroy, params: { continue: 'true' }
        expect(controller.stored_location_for(:user)).to eq '/authorize'
      end
    end

    context 'with a suspended user' do
      before do
        user.account.suspend!
      end

      it 'redirects to home after sign out' do
        sign_in(user, scope: :user)
        delete :destroy

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    context 'when using PAM authentication', if: ENV['PAM_ENABLED'] == 'true' do
      context 'when using a valid password' do
        before do
          post :create, params: { user: { email: 'pam_user1', password: '123456' } }
        end

        it 'redirects to home and logs the user in' do
          expect(response).to redirect_to(root_path)

          expect(controller.current_user).to be_instance_of(User)
        end
      end

      context 'when using an invalid password' do
        before do
          post :create, params: { user: { email: 'pam_user1', password: 'WRONGPW' } }
        end

        it 'shows a login error and does not log the user in' do
          expect(flash[:alert]).to match(/#{failure_message_invalid_email}/i)

          expect(controller.current_user).to be_nil
        end
      end

      context 'when using a valid email and existing user' do
        let!(:user) do
          account = Fabricate.build(:account, username: 'pam_user1', user: nil)
          account.save!(validate: false)
          user = Fabricate(:user, email: 'pam@example.com', password: nil, account: account, external: true)
          user
        end

        before do
          post :create, params: { user: { email: user.email, password: '123456' } }
        end

        it 'redirects to home and logs the user in' do
          expect(response).to redirect_to(root_path)

          expect(controller.current_user).to eq user
        end
      end
    end

    context 'when using password authentication' do
      let(:user) { Fabricate(:user, email: 'foo@bar.com', password: 'abcdefgh') }

      context 'when using a valid password' do
        subject do
          post :create, params: { user: { email: user.email, password: user.password } }
        end

        it 'redirects to home and logs the user in' do
          expect { subject }
            .to change(user.login_activities.where(success: true), :count).by(1)

          expect(response).to redirect_to(root_path)

          expect(controller.current_user).to eq user
        end
      end

      context 'when using a valid password on a previously-used account with a new IP address' do
        subject { post :create, params: { user: { email: user.email, password: user.password } } }

        let(:previous_ip) { '1.2.3.4' }
        let(:current_ip)  { '4.3.2.1' }

        before do
          Fabricate(:login_activity, user: user, ip: previous_ip)
          allow(controller.request).to receive(:remote_ip).and_return(current_ip)
          user.update(current_sign_in_at: 1.month.ago)
        end

        it 'logs the user in and sends suspicious email and redirects home', :inline_jobs do
          emails = capture_emails { subject }

          expect(response)
            .to redirect_to(root_path)

          expect(controller.current_user)
            .to eq user

          expect(emails.size)
            .to eq(1)
          expect(emails.first)
            .to have_attributes(
              to: contain_exactly(user.email),
              subject: eq(I18n.t('user_mailer.suspicious_sign_in.subject'))
            )
        end
      end

      context 'when using email with uppercase letters' do
        before do
          post :create, params: { user: { email: user.email.upcase, password: user.password } }
        end

        it 'redirects to home and logs the user in' do
          expect(response).to redirect_to(root_path)

          expect(controller.current_user).to eq user
        end
      end

      context 'when using an invalid password' do
        before do
          post :create, params: { user: { email: user.email, password: 'wrongpw' } }
        end

        it 'shows a login error and does not log the user in' do
          expect(flash[:alert]).to match(/#{failure_message_invalid_email}/i)

          expect(controller.current_user).to be_nil
        end
      end

      context 'when using an unconfirmed password' do
        before do
          request.headers['Accept-Language'] = accept_language
          post :create, params: { user: { email: unconfirmed_user.email, password: unconfirmed_user.password } }
        end

        let(:unconfirmed_user) { user.tap { |u| u.update!(confirmed_at: nil) } }
        let(:accept_language) { 'fr' }

        it 'redirects to home' do
          expect(response).to redirect_to(root_path)
        end
      end

      context "when logging in from the user's page" do
        before do
          allow(controller).to receive(:single_user_mode?).and_return(single_user_mode)
          allow(controller).to receive(:stored_location_for).with(:user).and_return("/@#{user.account.username}")
          post :create, params: { user: { email: user.email, password: user.password } }
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

    context 'when using two-factor authentication' do
      context 'with OTP enabled as second factor' do
        let!(:user) do
          Fabricate(:user, email: 'x@y.com', password: 'abcdefgh', otp_required_for_login: true, otp_secret: User.generate_otp_secret)
        end

        let!(:recovery_codes) do
          codes = user.generate_otp_backup_codes!
          user.save
          return codes
        end

        context 'when using email and password' do
          before do
            post :create, params: { user: { email: user.email, password: user.password } }
          end

          it 'renders two factor authentication page' do
            expect(response.body)
              .to include(I18n.t('simple_form.hints.sessions.otp'))
          end
        end

        context 'when using email and password after an unfinished log-in attempt to a 2FA-protected account' do
          let!(:other_user) do
            Fabricate(:user, email: 'z@y.com', password: 'abcdefgh', otp_required_for_login: true, otp_secret: User.generate_otp_secret)
          end

          before do
            post :create, params: { user: { email: other_user.email, password: other_user.password } }
            post :create, params: { user: { email: user.email, password: user.password } }
          end

          it 'renders two factor authentication page' do
            expect(response.body)
              .to include(I18n.t('simple_form.hints.sessions.otp'))
          end
        end

        context 'when using upcase email and password' do
          before do
            post :create, params: { user: { email: user.email.upcase, password: user.password } }
          end

          it 'renders two factor authentication page' do
            expect(response.body)
              .to include(I18n.t('simple_form.hints.sessions.otp'))
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

              post :create, params: { user: { otp_attempt: user.current_otp } }, session: { attempt_user_id: user.id, attempt_user_updated_at: user.updated_at.to_s }
            end

            expect(controller.current_user)
              .to be_nil

            expect(flash[:alert])
              .to match I18n.t('users.rate_limited')

            expect(emails.size)
              .to eq(1)
            expect(emails.first)
              .to have_attributes(
                to: contain_exactly(user.email),
                subject: eq(I18n.t('user_mailer.failed_2fa.subject'))
              )
          end

          def process_maximum_two_factor_attempts
            Auth::SessionsController::MAX_2FA_ATTEMPTS_PER_HOUR.times do
              post :create, params: { user: { otp_attempt: '1234' } }, session: { attempt_user_id: user.id, attempt_user_updated_at: user.updated_at.to_s }
              expect(controller.current_user).to be_nil
            end
          end
        end

        context 'when using a valid OTP' do
          before do
            post :create, params: { user: { otp_attempt: user.current_otp } }, session: { attempt_user_id: user.id, attempt_user_updated_at: user.updated_at.to_s }
          end

          it 'redirects to home and logs the user in' do
            expect(response).to redirect_to(root_path)

            expect(controller.current_user).to eq user
          end
        end

        context 'when the server has an decryption error' do
          before do
            allow(user).to receive(:validate_and_consume_otp!).with(user.current_otp).and_raise(OpenSSL::Cipher::CipherError)
            allow(User).to receive(:find_by).with(id: user.id).and_return(user)

            post :create, params: { user: { otp_attempt: user.current_otp } }, session: { attempt_user_id: user.id, attempt_user_updated_at: user.updated_at.to_s }
          end

          it 'shows a login error and does not log the user in' do
            expect(flash[:alert]).to match I18n.t('users.invalid_otp_token')

            expect(controller.current_user).to be_nil
          end
        end

        context 'when using a valid recovery code' do
          before do
            post :create, params: { user: { otp_attempt: recovery_codes.first } }, session: { attempt_user_id: user.id, attempt_user_updated_at: user.updated_at.to_s }
          end

          it 'redirects to home and logs the user in' do
            expect(response).to redirect_to(root_path)

            expect(controller.current_user).to eq user
          end
        end

        context 'when using an invalid OTP' do
          before do
            post :create, params: { user: { otp_attempt: 'wrongotp' } }, session: { attempt_user_id: user.id, attempt_user_updated_at: user.updated_at.to_s }
          end

          it 'shows a login error and does not log the user in' do
            expect(flash[:alert]).to match I18n.t('users.invalid_otp_token')

            expect(controller.current_user).to be_nil
          end
        end
      end

      context 'with WebAuthn and OTP enabled as second factor' do
        let!(:user) do
          Fabricate(:user, email: 'x@y.com', password: 'abcdefgh', otp_required_for_login: true, otp_secret: User.generate_otp_secret)
        end

        let!(:webauthn_credential) do
          user.update(webauthn_id: WebAuthn.generate_user_id)
          public_key_credential = WebAuthn::Credential.from_create(fake_client.create)
          user.webauthn_credentials.create(
            nickname: 'SecurityKeyNickname',
            external_id: public_key_credential.id,
            public_key: public_key_credential.public_key,
            sign_count: '1000'
          )
          user.webauthn_credentials.take
        end

        let(:domain) { "#{Rails.configuration.x.use_https ? 'https' : 'http'}://#{Rails.configuration.x.web_domain}" }

        let(:fake_client) { WebAuthn::FakeClient.new(domain) }

        let(:challenge) { WebAuthn::Credential.options_for_get.challenge }

        let(:sign_count) { 1234 }

        let(:fake_credential) { fake_client.get(challenge: challenge, sign_count: sign_count) }

        before do
          user.generate_otp_backup_codes!
          user.save
        end

        context 'when using email and password' do
          before do
            post :create, params: { user: { email: user.email, password: user.password } }
          end

          it 'renders webauthn authentication page' do
            expect(response.body)
              .to include(I18n.t('simple_form.title.sessions.webauthn'))
          end
        end

        context 'when using upcase email and password' do
          before do
            post :create, params: { user: { email: user.email.upcase, password: user.password } }
          end

          it 'renders webauthn authentication page' do
            expect(response.body)
              .to include(I18n.t('simple_form.title.sessions.webauthn'))
          end
        end

        context 'when using a valid webauthn credential' do
          before do
            controller.session[:webauthn_challenge] = challenge

            post :create, params: { user: { credential: fake_credential } }, session: { attempt_user_id: user.id, attempt_user_updated_at: user.updated_at.to_s }
          end

          it 'instructs the browser to redirect to home, logs the user in, and updates the sign count' do
            expect(response.parsed_body[:redirect_path]).to eq(root_path)

            expect(controller.current_user).to eq user

            expect(webauthn_credential.reload.sign_count).to eq(sign_count)
          end
        end
      end
    end

    def failure_message_invalid_email
      I18n.t('devise.failure.invalid', authentication_keys: I18n.t('activerecord.attributes.user.email'))
    end
  end
end
