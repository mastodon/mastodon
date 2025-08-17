# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Follow Recommendations' do
  describe 'PUT /admin/follow_recommendations' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      put admin_follow_recommendations_path(form_account_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_follow_recommendations_path)
    end
  end
end
