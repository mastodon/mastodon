# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAuth Authorizations' do
  let(:application) { Fabricate :application, name: 'test', redirect_uri: 'http://localhost/', scopes: 'read' }
  let(:params) { { client_id: application.uid, response_type: 'code', redirect_uri: 'http://localhost/', scope: 'read' } }

  describe 'GET #new' do
    subject { get oauth_authorization_path(params) }

    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before { sign_in user }

      it 'returns http success and private cache control headers' do
        subject

        expect(response)
          .to have_http_status(:success)
        expect(response.headers['Cache-Control'])
          .to include('private, no-store')
        expect(response.parsed_body.at('body.modal-layout'))
          .to be_present
        expect(controller.stored_location_for(:user))
          .to eq authorize_path_for(application)
      end

      context 'when app is already authorized' do
        before do
          Doorkeeper::AccessToken.find_or_create_for(
            application: application,
            resource_owner: user.id,
            scopes: application.scopes,
            expires_in: Doorkeeper.configuration.access_token_expires_in,
            use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
          )
        end

        it 'redirects to callback' do
          subject

          expect(response)
            .to redirect_to(/\A#{application.redirect_uri}/)
        end

        context 'with `force_login` param true' do
          subject do
            get oauth_authorization_path(params.merge(force_login: 'true'))
          end

          it 'renders new page with success status' do
            subject

            expect(response)
              .to have_http_status(:success)
            expect(response.parsed_body.title)
              .to match(I18n.t('doorkeeper.authorizations.new.title'))
          end
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        subject

        expect(response)
          .to redirect_to(new_user_session_path)
        expect(controller.stored_location_for(:user))
          .to eq authorize_path_for(application)
      end
    end

    def authorize_path_for(application)
      "/oauth/authorize?client_id=#{application.uid}&redirect_uri=http%3A%2F%2Flocalhost%2F&response_type=code&scope=read"
    end
  end
end
