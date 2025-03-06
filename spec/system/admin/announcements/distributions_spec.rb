# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Announcement Mail Distributions' do
  let(:user) { Fabricate(:admin_user) }
  let(:announcement) { Fabricate(:announcement, notification_sent_at: nil) }

  before { sign_in(user) }

  describe 'Sending an announcement notification', :inline_jobs do
    it 'marks the announcement as notified and sends the email' do
      visit admin_announcement_preview_path(announcement)
      expect(page)
        .to have_title(I18n.t('admin.announcements.preview.title'))

      emails = capture_emails do
        expect { click_on I18n.t('admin.terms_of_service.preview.send_to_all', count: 1, display_count: 1) }
          .to(change { announcement.reload.notification_sent_at })
      end
      expect(emails.first)
        .to be_present
        .and(deliver_to(user.email))
      expect(page)
        .to have_title(I18n.t('admin.announcements.title'))
    end
  end
end
