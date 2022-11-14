# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::CustomEmojisController, type: :request do
  path '/api/v1/custom_emojis' do
    get('list custom_emojis') do
      tags 'Api', 'V1', 'CustomEmojis'
      operationId 'v1CustomemojisListCustomEmoji'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
