# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Rules' do
  describe 'POST /admin/rules' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_rules_path(rule: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
