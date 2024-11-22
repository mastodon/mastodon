# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardController do
  render_views

  describe 'GET #index' do
    let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Owner')) }

    before do
      stub_system_checks
      Fabricate :software_update
      sign_in(user)
    end

    it 'returns http success and body with system check messages' do
      get :index

      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          body: include(I18n.t('admin.system_checks.software_version_patch_check.message_html'))
        )
    end

    private

    def stub_system_checks
      stub_const 'Admin::SystemCheck::ACTIVE_CHECKS', [
        Admin::SystemCheck::SoftwareVersionCheck,
      ]
    end
  end
end
