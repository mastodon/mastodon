# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Domain Allows' do
  describe 'POST /admin/domain_allows' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_domain_allows_path(domain_allow: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
