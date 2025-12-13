# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Custom Emojis' do
  describe 'POST /admin/custom_emojis' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_custom_emojis_path(custom_emoji: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
