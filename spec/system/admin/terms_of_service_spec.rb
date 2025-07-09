# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Terms of services' do
  describe 'Viewing terms of services index page' do
    let!(:terms) { Fabricate :terms_of_service, text: 'Test terms' }

    before { sign_in Fabricate(:admin_user) }

    it 'allows tags listing and editing' do
      visit admin_terms_of_service_index_path

      expect(page)
        .to have_title(I18n.t('admin.terms_of_service.title'))

      expect(page)
        .to have_content(terms.text)
    end
  end
end
