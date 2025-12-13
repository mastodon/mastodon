# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Statuses Cleanup' do
  describe 'PUT /statuses_cleanup' do
    before { sign_in Fabricate(:user) }

    it 'gracefully handles invalid nested params' do
      put statuses_cleanup_path(account_statuses_cleanup_policy: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
