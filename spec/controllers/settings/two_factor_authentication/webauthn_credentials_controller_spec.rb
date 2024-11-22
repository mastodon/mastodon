# frozen_string_literal: true

require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe Settings::TwoFactorAuthentication::WebauthnCredentialsController do
  render_views

  let(:user) { Fabricate(:user) }
  let(:domain) { "#{Rails.configuration.x.use_https ? 'https' : 'http'}://#{Rails.configuration.x.web_domain}" }
  let(:fake_client) { WebAuthn::FakeClient.new(domain) }

  def add_webauthn_credential(user)
    Fabricate(:webauthn_credential, user_id: user.id, nickname: 'USB Key')
  end

  describe 'GET #new' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      context 'when user has otp enabled' do
        before do
          user.update(otp_required_for_login: true)
        end

        it 'returns http success' do
          get :new

          expect(response).to have_http_status(200)
        end
      end

      context 'when user does not have otp enabled' do
        before do
          user.update(otp_required_for_login: false)
        end

        it 'requires otp enabled first' do
          get :new

          expect(response).to redirect_to settings_two_factor_authentication_methods_path
          expect(flash[:error]).to be_present
        end
      end
    end
  end

  describe 'GET #index' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      context 'when user has otp enabled' do
        before do
          user.update(otp_required_for_login: true)
        end

        context 'when user has webauthn enabled' do
          before do
            user.update(webauthn_id: WebAuthn.generate_user_id)
            add_webauthn_credential(user)
          end

          it 'returns http success' do
            get :index

            expect(response).to have_http_status(200)
          end
        end

        context 'when user does not has webauthn enabled' do
          it 'redirects to 2FA methods list page' do
            get :index

            expect(response).to redirect_to settings_two_factor_authentication_methods_path
            expect(flash[:error]).to be_present
          end
        end
      end

      context 'when user does not have otp enabled' do
        before do
          user.update(otp_required_for_login: false)
        end

        it 'requires otp enabled first' do
          get :index

          expect(response).to redirect_to settings_two_factor_authentication_methods_path
          expect(flash[:error]).to be_present
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to login' do
        delete :index

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET /options #options' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      context 'when user has otp enabled' do
        before do
          user.update(otp_required_for_login: true)
        end

        context 'when user has webauthn enabled' do
          before do
            user.update(webauthn_id: WebAuthn.generate_user_id)
            add_webauthn_credential(user)
          end

          it 'includes existing credentials in list of excluded credentials', :aggregate_failures do
            expect { get :options }.to_not change(user, :webauthn_id)

            expect(response).to have_http_status(200)

            expect(controller.session[:webauthn_challenge]).to be_present

            excluded_credentials_ids = response.parsed_body['excludeCredentials'].pluck('id')
            expect(excluded_credentials_ids).to match_array(user.webauthn_credentials.pluck(:external_id))
          end
        end

        context 'when user does not have webauthn enabled' do
          it 'stores the challenge on the session and sets user webauthn_id', :aggregate_failures do
            get :options

            expect(response).to have_http_status(200)
            expect(controller.session[:webauthn_challenge]).to be_present
            expect(user.reload.webauthn_id).to be_present
          end
        end
      end

      context 'when user has not enabled otp' do
        before do
          user.update(otp_required_for_login: false)
        end

        it 'requires otp enabled first' do
          get :options

          expect(response).to redirect_to settings_two_factor_authentication_methods_path
          expect(flash[:error]).to be_present
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to login' do
        get :options

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST #create' do
    let(:nickname) { 'SecurityKeyNickname' }

    let(:challenge) do
      WebAuthn::Credential.options_for_create(
        user: { id: user.id, name: user.account.username, display_name: user.account.display_name }
      ).challenge
    end

    let(:new_webauthn_credential) { fake_client.create(challenge: challenge) }

    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      context 'when user has enabled otp' do
        before do
          user.update(otp_required_for_login: true)
        end

        context 'when user has enabled webauthn' do
          before do
            user.update(webauthn_id: WebAuthn.generate_user_id)
            add_webauthn_credential(user)
          end

          it 'adds a new credential to user credentials and does not change webauthn_id when creation succeeds', :aggregate_failures do
            controller.session[:webauthn_challenge] = challenge

            expect do
              post :create, params: { credential: new_webauthn_credential, nickname: nickname }
            end.to change { user.webauthn_credentials.count }.by(1)
                                                             .and not_change(user, :webauthn_id)

            expect(response).to have_http_status(200)
          end

          it 'fails when the nickname is already used' do
            controller.session[:webauthn_challenge] = challenge

            post :create, params: { credential: new_webauthn_credential, nickname: 'USB Key' }

            expect(response).to have_http_status(422)
            expect(flash[:error]).to be_present
          end

          it 'fails when the credential already exists' do
            public_key_credential = WebAuthn::Credential.from_create(new_webauthn_credential)
            Fabricate(:webauthn_credential,
                      user_id: Fabricate(:user).id,
                      external_id: public_key_credential.id,
                      public_key: public_key_credential.public_key)

            controller.session[:webauthn_challenge] = challenge

            post :create, params: { credential: new_webauthn_credential, nickname: nickname }

            expect(response).to have_http_status(422)
            expect(flash[:error]).to be_present
          end
        end

        context 'when user have not enabled webauthn and creation succeeds' do
          it 'creates a webauthn credential' do
            controller.session[:webauthn_challenge] = challenge

            expect do
              post :create, params: { credential: new_webauthn_credential, nickname: nickname }
            end.to change { user.webauthn_credentials.count }.by(1)
          end
        end
      end

      context 'when user has not enabled otp' do
        before do
          user.update(otp_required_for_login: false)
        end

        it 'requires otp enabled first' do
          post :create, params: { credential: new_webauthn_credential, nickname: nickname }

          expect(response).to redirect_to settings_two_factor_authentication_methods_path
          expect(flash[:error]).to be_present
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to login' do
        post :create, params: { credential: new_webauthn_credential, nickname: nickname }

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
      end

      context 'when user has otp enabled' do
        before do
          user.update(otp_required_for_login: true)
        end

        context 'when user has webauthn enabled' do
          before do
            user.update(webauthn_id: WebAuthn.generate_user_id)
            add_webauthn_credential(user)
          end

          it 'redirects to 2FA methods list and shows flash success and deletes the credential when deletion succeeds', :aggregate_failures do
            expect do
              delete :destroy, params: { id: user.webauthn_credentials.take.id }
            end.to change { user.webauthn_credentials.count }.by(-1)

            expect(response).to redirect_to settings_two_factor_authentication_methods_path
            expect(flash[:success]).to be_present
          end
        end

        context 'when user does not have webauthn enabled' do
          it 'redirects to 2FA methods list and shows flash error' do
            delete :destroy, params: { id: '1' }

            expect(response).to redirect_to settings_two_factor_authentication_methods_path
            expect(flash[:error]).to be_present
          end
        end
      end

      context 'when user does not have otp enabled' do
        it 'requires otp enabled first' do
          delete :destroy, params: { id: '1' }

          expect(response).to redirect_to settings_two_factor_authentication_methods_path
          expect(flash[:error]).to be_present
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to login' do
        delete :destroy, params: { id: '1' }

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
