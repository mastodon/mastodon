# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin TermsOfService Previews' do
  let(:terms_of_service) { Fabricate(:terms_of_service, notification_sent_at: nil) }
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  describe 'Viewing TOS previews' do
    it 'shows the TOS preview page' do
      visit admin_terms_of_service_preview_path(terms_of_service)

      expect(page)
        .to have_title(I18n.t('admin.terms_of_service.preview.title'))
    end
  end
end
