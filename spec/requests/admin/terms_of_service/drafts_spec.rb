# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Terms Drafts' do
  describe 'PUT /admin/terms_of_service/draft' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      put admin_terms_of_service_draft_path(terms_of_service: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
