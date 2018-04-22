# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::SessionsController, type: :controller do
  render_views

  describe 'GET #new' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'returns http success' do
      get :new
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { Fabricate(:user) }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'with a regular user' do
      it 'redirects to home after sign out' do
        sign_in(user, scope: :user)
        delete :destroy

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a suspended user' do
      it 'redirects to home after sign out' do
        Fabricate(:account, user: user, suspended: true)
        sign_in(user, scope: :user)
        delete :destroy

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'using PAM authentication' do
      context 'using a valid password' do
        before do
          post :create, params: { user: { email: "pam_user1", password: '123456' } }
        end

        it 'redirects to home' do
          expect(response).to redirect_to(root_path)
        end

        it 'logs the user in' do
          expect(controller.current_user).to be_instance_of(User)
        end
      end

      context 'using an invalid password' do
        before do
          post :create, params: { user: { email: "pam_user1", password: 'WRONGPW' } }
        end

        it 'shows a login error' do
          expect(flash[:alert]).to match I18n.t('devise.failure.invalid', authentication_keys: 'Email')
        end

        it "doesn't log the user in" do
          expect(controller.current_user).to be_nil
        end
      end

      context 'using a valid email and existing user' do
        let(:user) do
          account = Fabricate.build(:account, username: 'pam_user1')
          account.save!(validate: false)
          user = Fabricate(:user, email: 'pam@example.com', password: nil, account: account)
          user
        end

        before do
          post :create, params: { user: { email: user.email, password: '123456' } }
        end

        it 'redirects to home' do
          expect(response).to redirect_to(root_path)
        end

        it 'logs the user in' do
          expect(controller.current_user).to eq user
        end
      end
    end

    context 'using password authentication' do
      let(:user) { Fabricate(:user, email: 'foo@bar.com', password: 'abcdefgh') }

      context 'using a valid password' do
        before do
          post :create, params: { user: { email: user.email, password: user.password } }
        end

        it 'redirects to home' do
          expect(response).to redirect_to(root_path)
        end

        it 'logs the user in' do
          expect(controller.current_user).to eq user
        end
      end

      context 'using email with uppercase letters' do
        before do
          post :create, params: { user: { email: user.email.upcase, password: user.password } }
        end

        it 'redirects to home' do
          expect(response).to redirect_to(root_path)
        end

        it 'logs the user in' do
          expect(controller.current_user).to eq user
        end
      end

      context 'using an invalid password' do
        before do
          post :create, params: { user: { email: user.email, password: 'wrongpw' } }
        end

        it 'shows a login error' do
          expect(flash[:alert]).to match I18n.t('devise.failure.invalid', authentication_keys: 'Email')
        end

        it "doesn't log the user in" do
          expect(controller.current_user).to be_nil
        end
      end

      context 'using an unconfirmed password' do
        before do
          request.headers['Accept-Language'] = accept_language
          post :create, params: { user: { email: unconfirmed_user.email, password: unconfirmed_user.password } }
        end

        let(:unconfirmed_user) { user.tap { |u| u.update!(confirmed_at: nil) } }
        let(:accept_language) { 'fr' }

        it 'shows a translated login error' do
          expect(flash[:alert]).to eq(I18n.t('devise.failure.unconfirmed', locale: accept_language))
        end
      end

      context "logging in from the user's page" do
        before do
          allow(controller).to receive(:single_user_mode?).and_return(single_user_mode)
          allow(controller).to receive(:stored_location_for).with(:user).and_return("/@#{user.account.username}")
          post :create, params: { user: { email: user.email, password: user.password } }
        end

        context "in single user mode" do
          let(:single_user_mode) { true }

          it 'redirects to home' do
            expect(response).to redirect_to(root_path)
          end
        end

        context "in non-single user mode" do
          let(:single_user_mode) { false }

          it "redirects back to the user's page" do
            expect(response).to redirect_to(short_account_path(username: user.account))
          end
        end
      end
    end

    context 'using two-factor authentication' do
      let(:user) do
        Fabricate(:user, email: 'x@y.com', password: 'abcdefgh',
                         otp_required_for_login: true, otp_secret: User.generate_otp_secret(32))
      end
      let(:recovery_codes) do
        codes = user.generate_otp_backup_codes!
        user.save
        return codes
      end

      context 'using email and password' do
        before do
          post :create, params: { user: { email: user.email, password: user.password } }
        end

        it 'renders two factor authentication page' do
          expect(controller).to render_template("two_factor")
        end
      end

      context 'using upcase email and password' do
        before do
          post :create, params: { user: { email: user.email.upcase, password: user.password } }
        end

        it 'renders two factor authentication page' do
          expect(controller).to render_template("two_factor")
        end
      end

      context 'using a valid OTP' do
        before do
          post :create, params: { user: { otp_attempt: user.current_otp } }, session: { otp_user_id: user.id }
        end

        it 'redirects to home' do
          expect(response).to redirect_to(root_path)
        end

        it 'logs the user in' do
          expect(controller.current_user).to eq user
        end
      end

      context 'when the server has an decryption error' do
        before do
          allow_any_instance_of(User).to receive(:validate_and_consume_otp!).and_raise(OpenSSL::Cipher::CipherError)
          post :create, params: { user: { otp_attempt: user.current_otp } }, session: { otp_user_id: user.id }
        end

        it 'shows a login error' do
          expect(flash[:alert]).to match I18n.t('users.invalid_otp_token')
        end

        it "doesn't log the user in" do
          expect(controller.current_user).to be_nil
        end
      end

      context 'using a valid recovery code' do
        before do
          post :create, params: { user: { otp_attempt: recovery_codes.first } }, session: { otp_user_id: user.id }
        end

        it 'redirects to home' do
          expect(response).to redirect_to(root_path)
        end

        it 'logs the user in' do
          expect(controller.current_user).to eq user
        end
      end

      context 'using an invalid OTP' do
        before do
          post :create, params: { user: { otp_attempt: 'wrongotp' } }, session: { otp_user_id: user.id }
        end

        it 'shows a login error' do
          expect(flash[:alert]).to match I18n.t('users.invalid_otp_token')
        end

        it "doesn't log the user in" do
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
