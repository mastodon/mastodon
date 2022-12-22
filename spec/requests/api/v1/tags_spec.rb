# frozen_string_literal: true

require 'rails_helper'

describe '/api/v1/tags' do
  let!(:tag) { Fabricate(:tag) }

  describe 'GET /api/v1/tags/:id' do
    context 'when not authenticated' do
      it 'returns the expected JSON' do
        get "/api/v1/tags/#{tag.name}"

        expect(response.body).to match_json_schema('tag')
      end

      it 'omits the `following` flag in the JSON body' do
        get "/api/v1/tags/#{tag.name}"

        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json).not_to have_key(:following)
      end

      it 'returns not found error JSON when the tag is invalid' do
        get '/api/v1/tags/invalid-tag'

        expect(response.body).to eq '{"error":"Not Found"}'
      end
    end

    context 'when authenticated' do
      let!(:user) { Fabricate(:user) }
      let!(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
      authorized_scopes = %w[follow read read:follows write:follows]
      unauthorized_scopes = Doorkeeper.configuration.scopes.all - authorized_scopes

      unauthorized_scopes.each do |scope|
        context "when unauthorized with #{scope}" do
          let!(:scopes) { scope }

          before do
            Fabricate(:tag_follow, tag: tag, account: user.account)
          end

          it 'returns the expected JSON' do
            get "/api/v1/tags/#{tag.name}", headers: { authorization: "Bearer #{token.token}" }

            expect(response.body).to match_json_schema('tag')
          end

          it 'omits the `following` flag in the JSON body' do
            get "/api/v1/tags/#{tag.name}", headers: { authorization: "Bearer #{token.token}" }

            json = JSON.parse(response.body).deep_symbolize_keys
            expect(json).not_to have_key(:following)
          end
        end
      end

      authorized_scopes.each do |scope|
        context "when authorized with #{scope} " do
          let!(:scopes) { :read }

          context 'when not following the tag' do
            it 'includes `following` flag with value `false`' do
              get "/api/v1/tags/#{tag.name}", headers: { authorization: "Bearer #{token.token}" }

              json = JSON.parse(response.body).deep_symbolize_keys
              expect(json[:following]).to be false
            end
          end

          context 'when following the tag' do
            before do
              Fabricate(:tag_follow, tag: tag, account: user.account)
            end

            it 'includes `following` flag with value `true`' do
              get "/api/v1/tags/#{tag.name}", headers: { authorization: "Bearer #{token.token}" }

              json = JSON.parse(response.body).deep_symbolize_keys
              expect(json[:following]).to be true
            end
          end
        end
      end
    end
  end

  describe 'POST /api/v1/tags/:id/follow' do
    context 'when not authenticated' do
      it 'returns token invalid error JSON' do
        post "/api/v1/tags/#{tag.name}/follow"

        expect(response.body).to eq '{"error":"The access token is invalid"}'
      end

      it 'returns unauthorized status' do
        post "/api/v1/tags/#{tag.name}/follow"

        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when authenticated' do
      let!(:user)   { Fabricate(:user) }
      let!(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
      authorized_scopes = %w[follow write write:follows]
      unauthorized_scopes = Doorkeeper.configuration.scopes.all - authorized_scopes

      unauthorized_scopes.each do |scope|
        context "when unauthorized with #{scope}" do
          let(:scopes) { scope }

          it 'returns forbidden status' do
            post "/api/v1/tags/#{tag.name}/follow", headers: { authorization: "Bearer #{token.token}" }

            expect(response).to have_http_status :forbidden
          end

          it 'returns authorization error JSON' do
            post "/api/v1/tags/#{tag.name}/follow", headers: { authorization: "Bearer #{token.token}" }

            expect(response.body).to eq '{"error":"This action is outside the authorized scopes"}'
          end
        end
      end

      authorized_scopes.each do |scope|
        context "when authorized with #{scope}" do
          let(:scopes) { scope }

          it 'returns ok status' do
            post "/api/v1/tags/#{tag.name}/follow", headers: { authorization: "Bearer #{token.token}" }

            expect(response).to have_http_status :ok
          end

          it 'returns the expected JSON' do
            post "/api/v1/tags/#{tag.name}/follow", headers: { authorization: "Bearer #{token.token}" }

            expect(response.body).to match_json_schema('tag')
          end

          it 'includes the `following` flag with value `true`' do
            post "/api/v1/tags/#{tag.name}/follow", headers: { authorization: "Bearer #{token.token}" }

            json = JSON.parse(response.body).deep_symbolize_keys
            expect(json[:following]).to be true
          end

          context 'when the tag is already followed' do
            before do
              Fabricate(:tag_follow, tag: tag, account: user.account)
            end

            it 'returns ok status' do
              post "/api/v1/tags/#{tag.name}/follow", headers: { authorization: "Bearer #{token.token}" }

              expect(response).to have_http_status :ok
            end

            it 'returns the expected JSON' do
              post "/api/v1/tags/#{tag.name}/follow", headers: { authorization: "Bearer #{token.token}" }

              expect(response.body).to match_json_schema('tag')
            end

            it 'includes the `following` flag with value `true`' do
              post "/api/v1/tags/#{tag.name}/follow", headers: { authorization: "Bearer #{token.token}" }

              json = JSON.parse(response.body).deep_symbolize_keys
              expect(json[:following]).to be true
            end
          end
        end
      end
    end
  end

  describe 'POST /api/v1/tags/:id/unfollow' do
    context 'when not authenticated' do
      it 'returns token invalid error JSON' do
        post "/api/v1/tags/#{tag.name}/unfollow"

        expect(response.body).to eq '{"error":"The access token is invalid"}'
      end

      it 'returns unauthorized status' do
        post "/api/v1/tags/#{tag.name}/unfollow"

        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when authenticated' do
      let!(:user)   { Fabricate(:user) }
      let!(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
      authorized_scopes = %w[follow write write:follows]
      unauthorized_scopes = Doorkeeper.configuration.scopes.all - authorized_scopes

      unauthorized_scopes.each do |scope|
        context "when unauthorized with #{scope}" do
          let(:scopes) { scope }

          it 'returns forbidden status' do
            post "/api/v1/tags/#{tag.name}/unfollow", headers: { authorization: "Bearer #{token.token}" }

            expect(response).to have_http_status :forbidden
          end

          it 'returns authorization error JSON' do
            post "/api/v1/tags/#{tag.name}/unfollow", headers: { authorization: "Bearer #{token.token}" }

            expect(response.body).to eq '{"error":"This action is outside the authorized scopes"}'
          end
        end
      end

      authorized_scopes.each do |scope|
        context "when authorized with #{scope}" do
          let(:scopes) { scope }

          context 'when the tag is followed' do
            before do
              Fabricate(:tag_follow, tag: tag, account: user.account)
            end

            it 'returns ok status' do
              post "/api/v1/tags/#{tag.name}/unfollow", headers: { authorization: "Bearer #{token.token}" }

              expect(response).to have_http_status :ok
            end

            it 'returns the expected JSON' do
              post "/api/v1/tags/#{tag.name}/unfollow", headers: { authorization: "Bearer #{token.token}" }

              expect(response.body).to match_json_schema('tag')
            end

            it 'includes the `following` flag with value `false`' do
              post "/api/v1/tags/#{tag.name}/unfollow", headers: { authorization: "Bearer #{token.token}" }

              json = JSON.parse(response.body).deep_symbolize_keys
              expect(json[:following]).to be false
            end
          end

          context 'when the tag is not followed' do
            it 'returns ok status' do
              post "/api/v1/tags/#{tag.name}/unfollow", headers: { authorization: "Bearer #{token.token}" }

              expect(response).to have_http_status :ok
            end

            it 'returns the expected JSON' do
              post "/api/v1/tags/#{tag.name}/unfollow", headers: { authorization: "Bearer #{token.token}" }

              expect(response.body).to match_json_schema('tag')
            end

            it 'includes the `following` flag with value `false`' do
              post "/api/v1/tags/#{tag.name}/unfollow", headers: { authorization: "Bearer #{token.token}" }

              json = JSON.parse(response.body).deep_symbolize_keys
              expect(json[:following]).to be false
            end
          end
        end
      end
    end
  end
end
