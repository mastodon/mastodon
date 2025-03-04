# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin TermsOfService Distributions' do
  let(:user) { Fabricate(:admin_user) }
  let(:terms_of_service) { Fabricate(:terms_of_service, notification_sent_at: nil) }

  before { sign_in(user) }

  describe 'Sending a TOS change notification', :inline_jobs do
    it 'marks the TOS as notified and sends the email' do
      visit admin_terms_of_service_preview_path(terms_of_service)
      expect(page)
        .to have_title(I18n.t('admin.terms_of_service.preview.title'))

      emails = capture_emails do
        expect { click_on I18n.t('admin.terms_of_service.preview.send_to_all', count: 1, display_count: 1) }
          .to(change { terms_of_service.reload.notification_sent_at })
      end
      expect(emails.first)
        .to be_present
        .and(deliver_to(user.email))
      expect(page)
        .to have_title(I18n.t('admin.terms_of_service.title'))
    end
  end
end
