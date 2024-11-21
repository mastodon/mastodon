# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Privacy Policy' do
  describe 'GET /api/v1/instance/privacy_policy' do
    it 'returns http success' do
      get api_v1_instance_privacy_policy_path

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect(response.parsed_body)
        .to be_present
        .and include(:content)
    end
  end
end
