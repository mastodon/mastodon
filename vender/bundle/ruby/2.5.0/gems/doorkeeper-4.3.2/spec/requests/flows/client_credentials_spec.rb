require 'spec_helper_integration'

describe 'Client Credentials Request' do
  let(:client) { FactoryBot.create :application }

  context 'a valid request' do
    it 'authorizes the client and returns the token response' do
      headers = authorization client.uid, client.secret
      params  = { grant_type: 'client_credentials' }

      post '/oauth/token', params, headers

      should_have_json 'access_token', Doorkeeper::AccessToken.first.token
      should_have_json_within 'expires_in', Doorkeeper.configuration.access_token_expires_in, 1
      should_not_have_json 'scope'
      should_not_have_json 'refresh_token'

      should_not_have_json 'error'
      should_not_have_json 'error_description'
    end

    context 'with scopes' do
      before do
        optional_scopes_exist :write
        default_scopes_exist :public
      end

      it 'adds the scope to the token an returns in the response' do
        headers = authorization client.uid, client.secret
        params  = { grant_type: 'client_credentials', scope: 'write' }

        post '/oauth/token', params, headers

        should_have_json 'access_token', Doorkeeper::AccessToken.first.token
        should_have_json 'scope', 'write'
      end

      context 'that are default' do
        it 'adds the scope to the token an returns in the response' do
          headers = authorization client.uid, client.secret
          params  = { grant_type: 'client_credentials', scope: 'public' }

          post '/oauth/token', params, headers

          should_have_json 'access_token', Doorkeeper::AccessToken.first.token
          should_have_json 'scope', 'public'
        end
      end

      context 'that are invalid' do
        it 'does not authorize the client and returns the error' do
          headers = authorization client.uid, client.secret
          params  = { grant_type: 'client_credentials', scope: 'random' }

          post '/oauth/token', params, headers

          should_have_json 'error', 'invalid_scope'
          should_have_json 'error_description', translated_error_message(:invalid_scope)
          should_not_have_json 'access_token'

          expect(response.status).to eq(401)
        end
      end
    end
  end

  context 'an invalid request' do
    it 'does not authorize the client and returns the error' do
      headers = {}
      params  = { grant_type: 'client_credentials' }

      post '/oauth/token', params, headers

      should_have_json 'error', 'invalid_client'
      should_have_json 'error_description', translated_error_message(:invalid_client)
      should_not_have_json 'access_token'

      expect(response.status).to eq(401)
    end
  end

  def authorization(username, password)
    credentials = ActionController::HttpAuthentication::Basic.encode_credentials username, password
    { 'HTTP_AUTHORIZATION' => credentials }
  end
end
