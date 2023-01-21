# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::DomainBlocksController do
  let(:block_domains) { %w(blocked1.com nosee.org get-rid-of.net) }

  path '/api/v1/domain_blocks' do
    get('show domain_block') do
      description 'View domains the user has blocked.'
      tags 'Api', 'V1', 'DomainBlocks'
      operationId 'v1DomainblocksShowDomainBlock'
      rswag_auth_scope ['follow', 'read', 'read:blocks']
      rswag_page_params limit_desc: <<~MD
        Maximum number of results to return.  
        Defaults to 100 domain blocks.  
        Max 200 domain blocks.
      MD

      response(
        200,
        <<~MD
          **successful**

          Sample call with limit=2.

          ```json
          ["nsfw.social","artalley.social"]
          ```

          Because AccountDomainBlock IDs are generally not exposed via any API responses,
          you will have to parse the HTTP Link header to load older or newer results.
          
          See [Paginating through API responses](https://docs.joinmastodon.org/api/guidelines/#pagination) for more information.

          ```
          Link: <https://mastodon.example/api/v1/domain_blocks?limit=2&max_id=16194>; rel="next", <https://mastodon.example/api/v1/domain_blocks?limit=2&since_id=16337>; rel="prev"
          ```
        MD
      ) do
        include_context 'user token auth' do
          let(:user_token_scopes) { 'follow read' }
        end

        before { block_domains.each { |domain| user.account.block_domain!(domain) } }

        rswag_add_examples!
        run_test!
      end

      response(401, 'Unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        include_context 'user token auth' do
          let(:user_token_scopes) { 'follow read' }
          let(:authorization) { 'Bearer xyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyz' }
        end
        rswag_add_examples!
        run_test!
      end

      response(403, 'Outside token scope') do
        schema '$ref' => '#/components/schemas/Error'
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:bookmarks' }
        end
        rswag_add_examples!
        run_test!
      end
    end

    delete('delete domain_block') do
      description 'Remove a domain block, if it exists in the user\'s array of blocked domains.'
      tags 'Api', 'V1', 'DomainBlocks'
      operationId 'v1DomainblocksDeleteDomainBlock'
      rswag_auth_scope ['follow', 'write', 'write:blocks']
      parameter name: :payload, in: :body, required: true, schema: {
        type: :object,
        properties: {
          domain: { type: :string },
        },
        required: %w(domain),
      }

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write' }
      end
      let!(:dom_block1) { AccountDomainBlock.create(account: user.account, domain: 'undesirable.net') }
      let!(:dom_block2) { AccountDomainBlock.create(account: user.account, domain: 'rather-not.com') }

      response(
        200,
        <<~MD
          **successful**

          If the call was successful, an empty object will be returned.

          Note that the call will be successful even if the domain was not previously blocked.
        MD
      ) do
        let(:payload) { { domain: 'undesirable.net' } }
        rswag_add_examples!
        run_test! do
          expect { dom_block1.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(user.account.domain_blocks).to have_attributes(count: 1).and(
            a_collection_containing_exactly(dom_block2)
          )
        end
      end

      response(200, 'unblock not blocked') do
        let(:payload) { { domain: 'never-blocked.com' } }
        rswag_add_examples!
        run_test! do
          expect(user.account.domain_blocks).to have_attributes(count: 2)
            .and(a_collection_including(dom_block2))
            .and(a_collection_including(dom_block1))
        end
      end

      response(401, 'Unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        let(:payload) { { domain: 'undesirable.net' } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'follow write' }
          let(:authorization) { 'Bearer xyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyz' }
        end
        rswag_add_examples!
        run_test!
      end

      response(403, 'Outside token scope') do
        schema '$ref' => '#/components/schemas/Error'
        let(:payload) { { domain: 'undesirable.net' } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:bookmarks' }
        end
        rswag_add_examples!
        run_test!
      end
    end

    post('create domain_block') do
      description <<~MD
        Block a domain to:

        - hide all public posts from it
        - hide all notifications from it
        - remove all followers from it
        - prevent following new users from it (but does not remove existing follows)
      MD
      tags 'Api', 'V1', 'DomainBlocks'
      operationId 'v1DomainblocksCreateDomainBlock'
      rswag_auth_scope ['follow', 'write', 'write:blocks']
      parameter name: :payload, in: :body, required: true, schema: {
        type: :object,
        properties: {
          domain: { type: :string },
        },
        required: %w(domain),
      }

      response(
        200,
        <<~MD
          **successful**

          If the call was successful, an empty object will be returned.
          
          Note that the call will be successful even if the domain is already blocked,
          or if the domain does not exist, or if the domain is not a domain.
        MD
      ) do
        let(:payload) { { domain: 'it-is-blocked.net' } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'follow write' }
        end
        rswag_add_examples!
        run_test! do
          expect(user.account.domain_blocks).to have_attributes(count: 1).and(
            a_collection_including(
              an_object_having_attributes(domain: payload[:domain])
            )
          )
        end
      end

      response(401, 'Unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        let(:payload) { { domain: 'it-is-blocked.net' } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'follow write' }
          let(:authorization) { 'Bearer xyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyz' }
        end
        rswag_add_examples!
        run_test!
      end

      response(403, 'Outside token scope') do
        schema '$ref' => '#/components/schemas/Error'
        let(:payload) { { domain: 'it-is-blocked.net' } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:bookmarks' }
        end
        rswag_add_examples!
        run_test!
      end

      response(422, 'No domain provided') do
        schema '$ref' => '#/components/schemas/Error'
        let(:payload) { { domain: '' } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'follow write' }
        end
        rswag_add_examples!
        run_test!
      end

      response(422, 'Invalid domain provided') do
        schema '$ref' => '#/components/schemas/Error'
        let(:payload) { { domain: 'not valid domain' } }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'follow write' }
        end
        rswag_add_examples!
        run_test!
      end
    end
  end
end
