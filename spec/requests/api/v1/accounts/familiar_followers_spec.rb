# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::FamiliarFollowersController, type: :request do
  path '/api/v1/accounts/familiar_followers' do
    get('list familiar_followers') do
      tags 'Api', 'V1', 'Accounts', 'FamiliarFollowers'
      operationId 'v1AccountsFamiliarfollowersListFamiliarFollower'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
