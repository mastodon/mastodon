# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Export Domain Allows' do
  before { sign_in Fabricate(:admin_user) }

  describe 'Viewing the domain allows import page' do
    it 'shows the upload form' do
      visit new_admin_export_domain_allow_path

      expect(page)
        .to have_title(I18n.t('admin.export_domain_allows.new.title'))
        .and have_field('admin_import_data', type: :file)
    end
  end

  describe 'Importing domain allows' do
    it 'allows the imported domains without importing the header' do
      visit new_admin_export_domain_allow_path

      # Invalid without file attached
      expect { click_on I18n.t('imports.upload') }
        .to_not change(DomainAllow, :count)
      expect(page)
        .to have_text(I18n.t('admin.export_domain_allows.no_file'))

      # Valid with file
      visit new_admin_export_domain_allow_path
      attach_file 'admin_import_data', file_fixture('domain_allows.csv')

      expect { click_on I18n.t('imports.upload') }
        .to change(DomainAllow, :count).by(2)

      expect(DomainAllow.pluck(:domain))
        .to contain_exactly('good.domain', 'better.domain')
      expect(page)
        .to have_current_path(admin_instances_path)
        .and have_text(I18n.t('admin.domain_allows.created_msg'))
    end
  end
end
