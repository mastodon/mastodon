# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Terms Generates' do
  describe 'POST /admin/terms_of_service/generates' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_terms_of_service_generate_path(terms_of_service_generator: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
