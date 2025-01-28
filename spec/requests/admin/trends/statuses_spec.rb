# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Trends Statuses' do
  describe 'POST /admin/trends/statuses/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_trends_statuses_path(trends_status_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_trends_statuses_path)
    end
  end
end
