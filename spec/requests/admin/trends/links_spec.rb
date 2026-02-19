# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Trends Links' do
  describe 'POST /admin/trends/links/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_trends_links_path(trends_preview_card_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_trends_links_path)
    end
  end
end
