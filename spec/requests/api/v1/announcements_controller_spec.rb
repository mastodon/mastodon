# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::AnnouncementsController do
  path '/api/v1/announcements/{id}/dismiss' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('dismiss announcement') do
      tags 'Api', 'V1', 'Announcements'
      operationId 'v1AnnouncementsDismissAnnouncement'
      rswag_auth_scope %w(write write:accounts)

      include_context 'user token auth'
      let(:account) { Fabricate(:account) }
      let!(:announcement) { Fabricate(:announcement) }

      before { announcement.publish! }

      response(200, 'successful') do
        let(:id) { announcement.id }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/announcements' do
    get('list announcements') do
      tags 'Api', 'V1', 'Announcements'
      operationId 'v1AnnouncementsListAnnouncement'
      rswag_auth_scope

      include_context 'user token auth'
      let!(:announcement) { Fabricate(:announcement) }
      before { announcement.publish! }

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Announcement' }
        rswag_add_examples!
        run_test!
      end
    end
  end
end
