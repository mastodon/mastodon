# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Polls::VotesController, type: :request do
  path '/api/v1/polls/{poll_id}/votes' do
    # You'll want to customize the parameter types...
    parameter name: 'poll_id', in: :path, type: :string, description: 'poll_id'

    post('create vote') do
      tags 'Api', 'V1', 'Polls', 'Votes'
      operationId 'v1PollsVotesCreateVote'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:poll_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end
