# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::Trends::TagsController do
  path '/api/v1/admin/trends/tags' do
    get('list tags') do
      tags 'Api', 'V1', 'Admin', 'Trends', 'Tags'
      operationId 'v1AdminTrendsTagsListTag'
      rswag_auth_scope %w(admin:read)
      parameter name: 'limit', in: :query, type: :integer, required: false,
                description: 'Maximum number of results to return. Defaults to 40.'
      parameter name: 'max_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'since_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'offset', in: :query, required: false, type: :integer

      include_context 'admin token auth'

      let(:account) { Fabricate(:account, trendable: true) }
      let(:status) { Fabricate(:status, trendable: true, language: 'en', account: account) }
      let!(:tag) { Fabricate(:tag, trendable: true, listable: true, usable: true, statuses: [status], accounts: [account]) }

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Tag' }
        # TODO: convince this controller to actually produce examples. This Tag Trends thing is a bit of a tricky thing here...
        rswag_add_examples!
        run_test!
        # analyse_body_run_test!
      end
    end
  end
end
