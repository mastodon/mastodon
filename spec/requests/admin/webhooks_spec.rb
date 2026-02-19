# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Webhooks' do
  describe 'POST /admin/webhooks' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_webhooks_path(webhook: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
