# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::MarkersController do
  path '/api/v1/markers' do
    get('list markers') do
      tags 'Api', 'V1', 'Markers'
      operationId 'v1MarkersListMarker'
      rswag_auth_scope %w(read read:statuses)
      parameter name: 'timeline[]', in: :query, required: false, schema: {
        type: :string,
        enum: %w(home notifications),
        description: <<~MD,
          Array of String. 
          Specify the timeline(s) for which markers should be fetched.
          
          Possible values: home, notifications.
          If not provided, an empty object will be returned.
        MD
      }

      include_context 'user token auth' do
        let(:user_token_scopes) { 'read:statuses' }
      end
      let!(:marker1) { user.markers.create(timeline: 'home') }

      response(200, 'successful') do
        # rubocop:disable Lint/SymbolConversion
        let('timeline[]'.to_sym) { 'home' }
        # rubocop:enable Lint/SymbolConversion
        rswag_add_examples!
        run_test!
      end
    end

    post('create marker') do
      tags 'Api', 'V1', 'Markers'
      operationId 'v1MarkersCreateMarker'
      rswag_auth_scope %w(write write:statuses)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'write:statuses' }
      end

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
