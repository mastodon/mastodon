# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::AnnouncementsController, type: :request do
  path '/api/v1/announcements/{id}/dismiss' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('dismiss announcement') do
      tags 'Api', 'V1', 'Announcements'
      operationId 'v1AnnouncementsDismissAnnouncement'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/announcements' do
    get('list announcements') do
      tags 'Api', 'V1', 'Announcements'
      operationId 'v1AnnouncementsListAnnouncement'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
