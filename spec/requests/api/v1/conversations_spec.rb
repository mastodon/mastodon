# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::ConversationsController, type: :request do
  path '/api/v1/conversations/{id}/read' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('read conversation') do
      tags 'Api', 'V1', 'Conversations'
      operationId 'v1ConversationsReadConversation'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/conversations' do
    get('list conversations') do
      tags 'Api', 'V1', 'Conversations'
      operationId 'v1ConversationsListConversation'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/conversations/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    delete('delete conversation') do
      tags 'Api', 'V1', 'Conversations'
      operationId 'v1ConversationsDeleteConversation'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end
