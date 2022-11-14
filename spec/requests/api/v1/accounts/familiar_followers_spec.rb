# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::FamiliarFollowersController, type: :request do
  path '/api/v1/accounts/familiar_followers' do
    get('list familiar_followers') do
      tags 'Api', 'V1', 'Accounts', 'FamiliarFollowers'
      operationId 'v1AccountsFamiliarfollowersListFamiliarFollower'
      rswag_auth_scope(%w(read read:follows))
      parameter name: 'id[]', in: :query, type: :string

      let(:account) { Fabricate(:account) }
      let(:alice)   { Fabricate(:account) }
      let(:bob)     { Fabricate(:account) }

      include_context 'user token auth' do
        let(:user) { account.user }
        let(:user_token_scopes) { 'read' }
      end

      response(200, 'lists familiar follows') do
        schema type: :array, items: {
          type: :object, properties: {
            id: { type: :string, pattern: '[0-9]+' },
            accounts: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Account' },
            },
          }
        }
        let('id[]') { alice.id }

        before do
          account.follow!(bob)
          alice.follow!(account)
          bob.follow!(alice)
        end

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to match_array([
                                        {
                                          id: alice.id.to_s,
                                          accounts: [
                                            a_hash_including({ 'id' => bob.id.to_s }),
                                          ],
                                        }.stringify_keys,
                                      ])
        end
      end

      response(200, 'no familiar follows') do
        schema type: :array, items: {
          type: :object, properties: {
            id: { type: :string, pattern: '[0-9]+' },
            accounts: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Account' },
            },
          }
        }
        let('id[]') { bob.id }

        before do
          account.follow!(bob)
          alice.follow!(account)
          bob.follow!(alice)
        end

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to match_array([
                                        {
                                          id: bob.id.to_s,
                                          accounts: [],
                                        }.stringify_keys,
                                      ])
        end
      end
    end
  end
end
