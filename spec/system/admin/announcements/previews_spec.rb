# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Announcements Mail Previews' do
  let(:admin_user) { Fabricate(:admin_user) }
  let(:announcement) { Fabricate(:announcement, notification_sent_at: nil) }

  before { sign_in(admin_user) }

  describe 'Viewing Announcements Mail previews' do
    it 'shows the Announcement Mail preview page' do
      visit admin_announcement_preview_path(announcement)

      expect(page)
        .to have_title(I18n.t('admin.announcements.preview.title'))
    end
  end
end
