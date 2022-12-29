# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Trends::LinksController do
  path '/api/v1/trends/links' do
    get('list links') do
      tags 'Api', 'V1', 'Trends', 'Links'
      operationId 'v1TrendsLinksListLink'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
