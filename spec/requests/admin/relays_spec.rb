# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Relays' do
  describe 'POST /admin/relays' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_relays_path(relay: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
