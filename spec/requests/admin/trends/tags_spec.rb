# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Trends Tags' do
  describe 'POST /admin/trends/tags/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_trends_tags_path(trends_tag_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_trends_tags_path)
    end
  end
end
