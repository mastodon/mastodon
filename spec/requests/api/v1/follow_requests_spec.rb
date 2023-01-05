# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FollowRequestsController do
  let!(:user) { Fabricate(:user) }
  let!(:other_account) { Fabricate(:user).account }
  let!(:other_req) do
    other_account.follow_requests.create!(target_account: user.account, show_reblogs: true, notify: false, rate_limit: false,
                                          bypass_follow_limit: true)
  end
  let!(:remote_account) { Fabricate(:account, domain: 'somewhere.else') }
  let!(:remote_req) do
    remote_account.follow_requests.create!(target_account: user.account, show_reblogs: true, notify: false, rate_limit: false,
                                           bypass_follow_limit: true)
  end

  path '/api/v1/follow_requests/{id}/authorize' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('authorize follow_request') do
      tags 'Api', 'V1', 'FollowRequests'
      operationId 'v1FollowrequestsAuthorizeFollowRequest'
      rswag_auth_scope %w(follow write write:follows)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write:follows' }
      end
      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { other_account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to include({ followed_by: true, following: false })
        end
      end
    end
  end

  path '/api/v1/follow_requests/{id}/reject' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('reject follow_request') do
      tags 'Api', 'V1', 'FollowRequests'
      operationId 'v1FollowrequestsRejectFollowRequest'
      rswag_auth_scope %w(follow write write:follows)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow write:follows' }
      end
      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:id) { remote_account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to include({ followed_by: false, following: false })
        end
      end
    end
  end

  path '/api/v1/follow_requests' do
    get('list follow_requests') do
      description <<~MD
        View pending follow requests

        Version history:
        - 0.0.0 - added
        - 3.3.0 - both min_id and max_id can be used at the same time now
      MD
      tags 'Api', 'V1', 'FollowRequests'
      operationId 'v1FollowrequestsListFollowRequest'
      rswag_auth_scope %w(follow read read:follows)
      rswag_page_params no_min_id: true, limit_desc: <<~MD
        Maximum number of results to return.  
        Defaults to 40 accounts.  
        Max 80 accounts.
      MD

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow read:follows' }
      end

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 2).and(
            match_array(
              [
                include({ id: other_account.id.to_s }),
                include({ id: remote_account.id.to_s }),
              ]
            )
          )
        end
      end
    end
  end
end
