# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Timelines::TagController do
  path '/api/v1/timelines/tag/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show tag') do
      tags 'Api', 'V1', 'Timelines', 'Tag'
      operationId 'v1TimelinesTagShowTag'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end
