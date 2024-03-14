# frozen_string_literal: true

require 'rails_helper'

describe Admin::DashboardController do
  render_views

  describe 'GET #index' do
    let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    before do
      stub_system_check_with_safe_results
      sign_in(user)
    end

    it 'returns http success' do
      get :index

      expect(response)
        .to have_http_status(200)

      expect(response.body)
        .to include(
          I18n.t('admin.system_checks.database_schema_check.message_html')
        )
    end

    private

    def stub_system_check_with_safe_results
      allow(Admin::SystemCheck)
        .to receive(:perform)
        .and_return(safe_system_check_messages)
    end

    def safe_system_check_messages
      [
        Admin::SystemCheck::Message.new(:database_schema_check),
        Admin::SystemCheck::Message.new(:rules_check, nil, admin_rules_path),
        Admin::SystemCheck::Message.new(:sidekiq_process_check, 'foo, bar'),
      ]
    end
  end
end
