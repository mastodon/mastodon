# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin SiteUploads' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in(user) }

  describe 'Removing a site upload' do
    let!(:site_upload) { Fabricate(:site_upload, var: 'thumbnail') }

    it 'removes the upload and redirects' do
      visit admin_settings_branding_path
      expect(page)
        .to have_title(I18n.t('admin.settings.branding.title'))

      expect { click_on I18n.t('admin.site_uploads.delete') }
        .to change(SiteUpload, :count).by(-1)
      expect { site_upload.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(page)
        .to have_content(I18n.t('admin.site_uploads.destroyed_msg'))
        .and have_title(I18n.t('admin.settings.branding.title'))
    end
  end
end
