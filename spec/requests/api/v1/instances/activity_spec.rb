# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Activity' do
  describe 'GET /api/v1/instance/activity' do
    context 'with activity api enabled' do
      before { Setting.activity_api_enabled = true }

      it 'returns http success' do
        get api_v1_instance_activity_path

        expect(response)
          .to have_http_status(200)

        expect(response.parsed_body)
          .to be_present
          .and(be_an(Array))
          .and(have_attributes(size: Api::V1::Instances::ActivityController::WEEKS_OF_ACTIVITY))
      end
    end

    context 'with activity api diabled' do
      before { Setting.activity_api_enabled = false }

      it 'returns not found' do
        get api_v1_instance_activity_path

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
