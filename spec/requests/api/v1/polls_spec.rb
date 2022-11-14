# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::PollsController, type: :request do
  path '/api/v1/polls' do
    post('create poll') do
      tags 'Api', 'V1', 'Polls'
      operationId 'v1PollsCreatePoll'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/polls/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show poll') do
      tags 'Api', 'V1', 'Polls'
      operationId 'v1PollsShowPoll'
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
