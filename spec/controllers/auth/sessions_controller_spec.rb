require 'rails_helper'

RSpec.describe Auth::SessionsController, type: :controller do
  render_views

  describe 'GET #new' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
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
