# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::Web::EmbedsController do
  path '/api/web/embed' do
    post('create embed') do
      tags 'Api', 'Web', 'Embeds'
      operationId 'webEmbedsCreateEmbed'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
