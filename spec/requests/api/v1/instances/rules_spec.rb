# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rules' do
  describe 'GET /api/v1/instance/rules' do
    it 'returns http success' do
      get api_v1_instance_rules_path

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect(response.parsed_body)
        .to be_an(Array)
    end
  end
end
