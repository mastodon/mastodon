# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::Web::SettingsController do
  path '/api/web/settings' do
    patch('update setting') do
      tags 'Api', 'Web', 'Settings'
      operationId 'webSettingsUpdateSetting'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    put('update setting') do
      tags 'Api', 'Web', 'Settings'
      operationId 'webSettingsUpdateSetting'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
