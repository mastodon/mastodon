# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Export Domain Blocks' do
  describe 'POST /admin/export_domain_blocks/import' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post import_admin_export_domain_blocks_path(admin_import: 'invalid')

      expect(response.body)
        .to include(I18n.t('admin.export_domain_blocks.no_file'))
    end
  end
end
