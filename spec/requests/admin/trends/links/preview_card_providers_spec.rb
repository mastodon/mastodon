# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Trends Links Preview Card Providers' do
  describe 'POST /admin/trends/links/publishers/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_trends_links_preview_card_providers_path(trends_preview_card_provider_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_trends_links_preview_card_providers_path)
    end
  end
end
