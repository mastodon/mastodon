# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin TermsOfService Tests' do
  let(:user) { Fabricate(:admin_user) }
  let(:terms_of_service) { Fabricate(:terms_of_service, notification_sent_at: nil) }

  before { sign_in(user) }

  describe 'Sending test TOS email', :inline_jobs do
    it 'generates the test email' do
      visit admin_terms_of_service_preview_path(terms_of_service)
      expect(page)
        .to have_title(I18n.t('admin.terms_of_service.preview.title'))

      emails = capture_emails { click_on I18n.t('admin.terms_of_service.preview.send_preview', email: user.email) }
      expect(emails.first)
        .to be_present
        .and(deliver_to(user.email))
      expect(page)
        .to have_title(I18n.t('admin.terms_of_service.preview.title'))
    end
  end
end
