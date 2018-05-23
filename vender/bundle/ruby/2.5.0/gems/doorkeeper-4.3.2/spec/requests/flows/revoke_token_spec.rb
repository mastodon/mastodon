require 'spec_helper_integration'

describe 'Revoke Token Flow' do
  before do
    Doorkeeper.configure { orm DOORKEEPER_ORM }
  end

  context 'with default parameters' do
    let(:client_application) { FactoryBot.create :application }
    let(:resource_owner) { User.create!(name: 'John', password: 'sekret') }
    let(:access_token) do
      FactoryBot.create(:access_token,
                         application: client_application,
                         resource_owner_id: resource_owner.id,
                         use_refresh_token: true)
    end

    context 'with authenticated, confidential OAuth 2.0 client/application' do
      let(:headers) do
        client_id = client_application.uid
        client_secret = client_application.secret
        credentials = Base64.encode64("#{client_id}:#{client_secret}")
        { 'HTTP_AUTHORIZATION' => "Basic #{credentials}" }
      end

      it 'should revoke the access token provided' do
        post revocation_token_endpoint_url, { token: access_token.token }, headers

        access_token.reload

        expect(response).to be_successful
        expect(access_token.revoked?).to be_truthy
      end

      it 'should revoke the refresh token provided' do
        post revocation_token_endpoint_url, { token: access_token.refresh_token }, headers

        access_token.reload

        expect(response).to be_successful
        expect(access_token.revoked?).to be_truthy
      end

      context 'with invalid token to revoke' do
        it 'should not revoke any tokens and respond successfully' do
          num_prev_revoked_tokens = Doorkeeper::AccessToken.where(revoked_at: nil).count
          post revocation_token_endpoint_url, { token: 'I_AM_AN_INVALID_TOKEN' }, headers

          # The authorization server responds with HTTP status code 200 even if
          # token is invalid
          expect(response).to be_successful
          expect(Doorkeeper::AccessToken.where(revoked_at: nil).count).to eq(num_prev_revoked_tokens)
        end
      end

      context 'with bad credentials and a valid token' do
        let(:headers) do
          client_id = client_application.uid
          credentials = Base64.encode64("#{client_id}:poop")
          { 'HTTP_AUTHORIZATION' => "Basic #{credentials}" }
        end
        it 'should not revoke any tokens and respond successfully' do
          post revocation_token_endpoint_url, { token: access_token.token }, headers

          access_token.reload

          expect(response).to be_successful
          expect(access_token.revoked?).to be_falsey
        end
      end

      context 'with no credentials and a valid token' do
        it 'should not revoke any tokens and respond successfully' do
          post revocation_token_endpoint_url, { token: access_token.token }

          access_token.reload

          expect(response).to be_successful
          expect(access_token.revoked?).to be_falsey
        end
      end

      context 'with valid token for another client application' do
        let(:other_client_application) { FactoryBot.create :application }
        let(:headers) do
          client_id = other_client_application.uid
          client_secret = other_client_application.secret
          credentials = Base64.encode64("#{client_id}:#{client_secret}")
          { 'HTTP_AUTHORIZATION' => "Basic #{credentials}" }
        end

        it 'should not revoke the token as its unauthorized' do
          post revocation_token_endpoint_url, { token: access_token.token }, headers

          access_token.reload

          expect(response).to be_successful
          expect(access_token.revoked?).to be_falsey
        end
      end
    end

    context 'with public OAuth 2.0 client/application' do
      let(:access_token) do
        FactoryBot.create(:access_token,
                           application: nil,
                           resource_owner_id: resource_owner.id,
                           use_refresh_token: true)
      end

      it 'should revoke the access token provided' do
        post revocation_token_endpoint_url, { token: access_token.token }

        access_token.reload

        expect(response).to be_successful
        expect(access_token.revoked?).to be_truthy
      end

      it 'should revoke the refresh token provided' do
        post revocation_token_endpoint_url, { token: access_token.refresh_token }

        access_token.reload

        expect(response).to be_successful
        expect(access_token.revoked?).to be_truthy
      end

      context 'with a valid token issued for a confidential client' do
        let(:access_token) do
          FactoryBot.create(:access_token,
                             application: client_application,
                             resource_owner_id: resource_owner.id,
                             use_refresh_token: true)
        end

        it 'should not revoke the access token provided' do
          post revocation_token_endpoint_url, { token: access_token.token }

          access_token.reload

          expect(response).to be_successful
          expect(access_token.revoked?).to be_falsey
        end

        it 'should not revoke the refresh token provided' do
          post revocation_token_endpoint_url, { token: access_token.token }

          access_token.reload

          expect(response).to be_successful
          expect(access_token.revoked?).to be_falsey
        end
      end
    end
  end
end
