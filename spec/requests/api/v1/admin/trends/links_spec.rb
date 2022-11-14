# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::Trends::LinksController, type: :request do
  path '/api/v1/admin/trends/links' do
    get('list links') do
      tags 'Api', 'V1', 'Admin', 'Trends', 'Links'
      operationId 'v1AdminTrendsLinksListLink'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
