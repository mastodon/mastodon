# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::EndorsementsController do
  path '/api/v1/endorsements' do
    get('list endorsements') do
      description 'Accounts that the user is currently featuring on their profile.'
      tags 'Api', 'V1', 'Endorsements'
      operationId 'v1EndorsementsListEndorsement'
      rswag_auth_scope %w(read read:accounts)
      rswag_page_params no_min_id: true, limit_desc: <<~MD
        Maximum number of results to return.  
        Defaults to 40 accounts.  
        Returns unlimited, when `0`.
      MD

      response(
        200,
        <<~MD
          **successful**

          Because AccountPin IDs are generally not exposed via any API responses,
          you will have to parse the HTTP `Link` header to load older or newer results.
          See [Paginating through API responses](https://docs.joinmastodon.org/api/guidelines/#pagination)
          for more information.
          
          ```
          Link: <https://mastodon.example/api/v1/endorsements?limit=2&max_id=832844>; rel="next", <https://mastodon.example/api/v1/endorsements?limit=2&since_id=952529>; rel="prev"
          ```
        MD
      ) do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:accounts' }
        end
        let(:pinned1) { Fabricate(:user).account }
        let(:pinned2) { Fabricate(:account, domain: 'else.where') }

        before do
          user.account.follow!(pinned1)
          user.account.account_pins.create!(target_account: pinned1)
          user.account.follow!(pinned2)
          user.account.account_pins.create!(target_account: pinned2)
        end

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 2).and(
            match_array(
              [
                include({ id: pinned1.id.to_s }),
                include({ id: pinned2.id.to_s }),
              ]
            )
          )
        end
      end

      response(401, 'Unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:accounts' }
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
  end
end
