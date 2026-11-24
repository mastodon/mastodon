# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Dashboard' do
  describe 'Viewing the dashboard page' do
    let(:user) { Fabricate(:owner_user) }

    before do
      Fabricate :software_update
      Fabricate :tag, requested_review_at: 5.minutes.ago
      sign_in(user)
    end

    it 'returns page' do
      visit admin_dashboard_path

      expect(page)
        .to have_title(I18n.t('admin.dashboard.title'))
        .and have_text('0 pending hashtags')
    end
  end
end
