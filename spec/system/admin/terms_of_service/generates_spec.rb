# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin TermsOfService Generates' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  describe 'Generating a TOS policy' do
    it 'saves a new TOS from values' do
      visit admin_terms_of_service_generate_path
      expect(page)
        .to have_title(I18n.t('admin.terms_of_service.generates.title'))

      # Invalid form submission
      fill_in 'terms_of_service_generator_admin_email', with: 'what the'
      expect { submit_form }
        .to_not change(TermsOfService, :count)
      expect(page)
        .to have_title(I18n.t('admin.terms_of_service.generates.title'))

      # Valid submission
      fill_in 'terms_of_service_generator_admin_email', with: 'test@host.example'
      fill_in 'terms_of_service_generator_arbitration_address', with: '123 Main Street'
      fill_in 'terms_of_service_generator_arbitration_website', with: 'https://host.example'
      fill_in 'terms_of_service_generator_dmca_address', with: '123 DMCA Ave'
      fill_in 'terms_of_service_generator_dmca_email', with: 'dmca@host.example'
      fill_in 'terms_of_service_generator_domain', with: 'host.example'
      fill_in 'terms_of_service_generator_jurisdiction', with: 'Europe'
      fill_in 'terms_of_service_generator_choice_of_law', with: 'New York'
      fill_in 'terms_of_service_generator_min_age', with: '16'

      expect { submit_form }
        .to change(TermsOfService, :count).by(1)
      expect(page)
        .to have_title(I18n.t('admin.terms_of_service.title'))
    end

    def submit_form
      click_on I18n.t('admin.terms_of_service.generates.action')
    end
  end
end
