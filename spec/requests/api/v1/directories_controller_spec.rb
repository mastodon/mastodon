# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::DirectoriesController do
  path '/api/v1/directory' do
    get('show directory') do
      description 'List accounts visible in the directory.'
      tags 'Api', 'V1', 'Directories'
      operationId 'v1DirectoriesShowDirectory'
      rswag_auth_scope ['read'], auth_required: false
      parameter name: 'limit', in: :query, type: :integer, required: false,
                description: 'How many accounts to load. Defaults to 40 accounts. Max 80 accounts.'
      parameter name: 'offset', in: :query, type: :integer, required: false,
                description: 'Skip the first n results.'
      parameter name: 'order', in: :query, type: :string, required: false,
                description: <<~MD
                  Use `active` to sort by most recently posted statuses (default)
                  or `new` to sort by most recently created profiles.
                MD
      parameter name: 'local', in: :query, type: :boolean, required: false,
                description: 'If true, returns only local accounts.'

      include_context 'user token auth' do
        let!(:authorization) { nil }
      end
      let!(:account_local1) { user.account }
      let!(:account_local2) { Fabricate(:user).account }
      let!(:account_local_hidden) do
        user = Fabricate(:user)
        user.account.update(discoverable: false)
        user.account.reload
      end
      let!(:account_remote1) { Fabricate(:account, domain: 'somewhere.else') }
      let!(:account_remote2) { Fabricate(:account, domain: 'else.where') }
      let!(:account_remote_hidden) do
        Fabricate(:account, domain: 'somewhere.else', discoverable: false)
      end

      before do
        Mute.create(account: account_local1, target_account: account_local2)
        Block.create(account: account_local1, target_account: account_remote1)
        AccountDomainBlock.create(account: account_local1, domain: 'else.where')
      end

      response(200, 'returns all discoverable') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 4).and(
            match_array(
              [
                include({ id: account_local1.id.to_s }),
                include({ id: account_local2.id.to_s }),
                include({ id: account_remote1.id.to_s }),
                include({ id: account_remote2.id.to_s }),
              ]
            )
          )
        end
      end

      response(200, 'returns second page') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        let(:limit) { 2 }
        let(:offset) { 2 }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 2).and(
            match_array(
              [
                include({ id: account_local1.id.to_s }),
                include({ id: account_local2.id.to_s }),
              ]
            )
          )
        end
      end

      response(200, 'returns local') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        let(:local) { true }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 2).and(
            match_array(
              [
                include({ id: account_local1.id.to_s }),
                include({ id: account_local2.id.to_s }),
              ]
            )
          )
        end
      end

      response(200, 'returns for authenticated') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        let!(:authorization) { "Bearer #{user_token.token}" }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 1).and(
            match_array(
              [
                include({ id: account_local1.id.to_s }),
              ]
            )
          )
        end
      end
    end
  end
end
