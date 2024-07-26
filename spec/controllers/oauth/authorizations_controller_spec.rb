# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::AuthorizationsController do
  render_views

  let(:app) { Doorkeeper::Application.create!(name: 'test', redirect_uri: 'http://localhost/', scopes: 'read') }

  describe 'GET #new' do
    subject do
      get :new, params: { client_id: app.uid, response_type: 'code', redirect_uri: 'http://localhost/', scope: 'read' }
    end

    def body
      Nokogiri::Slop(response.body)
    end

    def error_message
      body.at_css('.form-container .flash-message').text
    end

    shared_examples 'shows authorize and deny buttons' do
      it 'gives options to authorize and deny' do
        subject

        authorize_button = body.at_css('.oauth-prompt button[type="submit"]:not(.negative)')
        deny_button = body.at_css('.oauth-prompt button[type="submit"].negative')

        expect(authorize_button).to be_present
        expect(deny_button).to be_present
      end
    end

    shared_examples 'stores location for user' do
      it 'stores location for user' do
        subject
        expect(controller.stored_location_for(:user)).to eq "/oauth/authorize?client_id=#{app.uid}&redirect_uri=http%3A%2F%2Flocalhost%2F&response_type=code&scope=read"
      end
    end

    context 'when signed in' do
      let!(:user) { Fabricate(:user) }

      before do
        sign_in user, scope: :user
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'returns private cache control headers' do
        subject
        expect(response.headers['Cache-Control']).to include('private, no-store')
      end

      include_examples 'shows authorize and deny buttons'

      include_examples 'stores location for user'

      context 'when app is already authorized' do
        before do
          Doorkeeper::AccessToken.find_or_create_for(
            application: app,
            resource_owner: user.id,
            scopes: app.scopes,
            expires_in: Doorkeeper.configuration.access_token_expires_in,
            use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
          )
        end

        it 'redirects to callback' do
          subject
          expect(response).to redirect_to(/\A#{app.redirect_uri}/)
        end

        it 'does not redirect to callback with force_login=true' do
          get :new, params: { client_id: app.uid, response_type: 'code', redirect_uri: 'http://localhost/', scope: 'read', force_login: 'true' }

          authorize_button = body.at_css('.oauth-prompt button[type="submit"]:not(.negative)')
          deny_button = body.at_css('.oauth-prompt button[type="submit"].negative')

          expect(authorize_button).to be_present
          expect(deny_button).to be_present
        end
      end

      # The tests in this context ensures that requests without PKCE parameters
      # still work; In the future we likely want to force usage of PKCE for
      # security reasons, as per:
      #
      # https://www.ietf.org/archive/id/draft-ietf-oauth-security-topics-27.html#section-2.1.1-9
      context 'when not using PKCE' do
        subject do
          get :new, params: { client_id: app.uid, response_type: 'code', redirect_uri: 'http://localhost/', scope: 'read' }
        end

        it 'returns http success' do
          subject
          expect(response).to have_http_status(200)
        end

        it 'does not include the PKCE values in the response' do
          subject

          code_challenge_input = body.at_css('.oauth-prompt input[name=code_challenge]')
          code_challenge_method_input = body.at_css('.oauth-prompt input[name=code_challenge_method]')

          expect(code_challenge_input).to be_present
          expect(code_challenge_method_input).to be_present

          expect(code_challenge_input.attr('value')).to be_nil
          expect(code_challenge_method_input.attr('value')).to be_nil
        end

        include_examples 'shows authorize and deny buttons'
      end

      context 'when using PKCE' do
        subject do
          get :new, params: { client_id: app.uid, response_type: 'code', redirect_uri: 'http://localhost/', scope: 'read', code_challenge_method: pkce_code_challenge_method, code_challenge: pkce_code_challenge }
        end

        let(:pkce_code_challenge) { SecureRandom.hex(32) }
        let(:pkce_code_challenge_method) { 'S256' }

        context 'when using S256 code challenge method' do
          it 'returns http success' do
            subject
            expect(response).to have_http_status(200)
          end

          it 'includes the PKCE values in the response' do
            subject

            code_challenge_input = body.at_css('.oauth-prompt input[name=code_challenge]')
            code_challenge_method_input = body.at_css('.oauth-prompt input[name=code_challenge_method]')

            expect(code_challenge_input).to be_present
            expect(code_challenge_method_input).to be_present

            expect(code_challenge_input.attr('value')).to eq pkce_code_challenge
            expect(code_challenge_method_input.attr('value')).to eq pkce_code_challenge_method
          end

          include_examples 'shows authorize and deny buttons'
        end

        context 'when using plain code challenge method' do
          subject do
            get :new, params: { client_id: app.uid, response_type: 'code', redirect_uri: 'http://localhost/', scope: 'read', code_challenge_method: pkce_code_challenge_method, code_challenge: pkce_code_challenge }
          end

          let(:pkce_code_challenge_method) { 'plain' }

          it 'returns http success' do
            subject
            expect(response).to have_http_status(400)
          end

          it 'does not include the PKCE values in the response' do
            subject

            code_challenge_input = body.at_css('.oauth-prompt input[name=code_challenge]')
            code_challenge_method_input = body.at_css('.oauth-prompt input[name=code_challenge_method]')

            expect(code_challenge_input).to_not be_present
            expect(code_challenge_method_input).to_not be_present
          end

          it 'does not include the authorize button' do
            subject

            authorize_button = body.at_css('.oauth-prompt button[type="submit"]')

            expect(authorize_button).to_not be_present
          end

          it 'includes an error message' do
            subject
            expect(error_message).to match I18n.t('doorkeeper.errors.messages.invalid_code_challenge_method')
          end
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        subject
        expect(response).to redirect_to '/auth/sign_in'
      end

      include_examples 'stores location for user'
    end
  end
end
