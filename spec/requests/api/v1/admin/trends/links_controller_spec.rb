# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::Trends::LinksController do
  path '/api/v1/admin/trends/links' do
    get('list links') do
      tags 'Api', 'V1', 'Admin', 'Trends', 'Links'
      operationId 'v1AdminTrendsLinksListLink'
      rswag_auth_scope(['admin:read'])
      parameter name: 'limit', in: :query, type: :integer, required: false,
                description: 'Maximum number of results to return. Defaults to 40.'
      parameter name: 'max_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'since_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'offset', in: :query, required: false, type: :integer

      include_context 'admin token auth'

      let!(:preview_cards) do
        Array.new(11) do
          Fabricate(
            :preview_card, language: 'en', trendable: true,
            trend: PreviewCardTrend.new(language: 'en', allowed: true, score: 1.0)
          )
        end
      end

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/PreviewCardLink' }
        let(:limit) { 2 }
        let(:page) { 1 }
        rswag_add_examples!
        run_test!
      end
    end
  end
end
