# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Announcements::ReactionsController, type: :request do
  path '/api/v1/announcements/{announcement_id}/reactions/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'announcement_id', in: :path, type: :string, description: 'announcement_id'
    parameter name: 'id', in: :path, type: :string, description: 'id'

    patch('update reaction') do
      tags 'Api', 'V1', 'Announcements', 'Reactions'
      operationId 'v1AnnouncementsReactionsUpdateReaction'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:announcement_id) { '123' }
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update reaction') do
      tags 'Api', 'V1', 'Announcements', 'Reactions'
      operationId 'v1AnnouncementsReactionsUpdateReaction'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:announcement_id) { '123' }
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete reaction') do
      tags 'Api', 'V1', 'Announcements', 'Reactions'
      operationId 'v1AnnouncementsReactionsDeleteReaction'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:announcement_id) { '123' }
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end
