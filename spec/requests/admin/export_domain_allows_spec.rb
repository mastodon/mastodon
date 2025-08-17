# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Export Domain Allows' do
  describe 'POST /admin/export_domain_allows/import' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post import_admin_export_domain_allows_path(admin_import: 'invalid')

      expect(response)
        .to redirect_to(admin_instances_path)
    end
  end
end
