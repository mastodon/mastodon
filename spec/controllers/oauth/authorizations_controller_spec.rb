# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::AuthorizationsController do
  let(:app) { Doorkeeper::Application.create!(name: 'test', redirect_uri: 'http://localhost/', scopes: 'read') }

  describe 'GET #new' do
    subject do
      get :new, params: { client_id: app.uid, response_type: 'code', redirect_uri: 'http://localhost/', scope: 'read' }
    end

    context 'when signed in' do
      let!(:user) { Fabricate(:user) }

      before do
        sign_in user, scope: :user
      end

      it 'returns http success and private cache control headers' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.headers['Cache-Control'])
          .to include('private, no-store')
        expect(controller.stored_location_for(:user))
          .to eq authorize_path_for(app)
      end

      context 'when app is already authorized' do
        before do
          context = Doorkeeper::OAuth::Authorization::Token.build_context(
            app,
            Doorkeeper::OAuth::AUTHORIZATION_CODE,
            app.scopes,
            user.id
          )

          Doorkeeper::AccessToken.find_or_create_for(
            application: context.client,
            resource_owner: context.resource_owner,
            scopes: context.scopes,
            expires_in: Doorkeeper::OAuth::Authorization::Token.access_token_expires_in(Doorkeeper.config, context),
            use_refresh_token: Doorkeeper::OAuth::Authorization::Token.refresh_token_enabled?(Doorkeeper.config, context)
          )
        end

        it 'redirects to callback' do
          subject
          expect(response).to redirect_to(/\A#{app.redirect_uri}/)
        end

        context 'with `force_login` param true' do
          subject do
            get :new, params: { client_id: app.uid, response_type: 'code', redirect_uri: 'http://localhost/', scope: 'read', force_login: 'true' }
          end

          it { is_expected.to have_http_status(:success) }
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        subject

        expect(response)
          .to redirect_to '/auth/sign_in'
        expect(controller.stored_location_for(:user))
          .to eq authorize_path_for(app)
      end
    end

    def authorize_path_for(app)
      "/oauth/authorize?client_id=#{app.uid}&redirect_uri=http%3A%2F%2Flocalhost%2F&response_type=code&scope=read"
    end
  end
end
