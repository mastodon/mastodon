# frozen_string_literal: true

require 'rails_helper'

describe Admin::DashboardController, type: :controller do
  render_views

  describe 'GET #index' do
    before do
      allow(Admin::SystemCheck).to receive(:perform).and_return([
        Admin::SystemCheck::Message.new(:database_schema_check),
        Admin::SystemCheck::Message.new(:rules_check, nil, admin_rules_path),
        Admin::SystemCheck::Message.new(:sidekiq_process_check, 'foo, bar'),
      ])
      sign_in Fabricate(:user, admin: true)
    end

    it 'returns 200' do
      get :index

      expect(response).to have_http_status(200)
    end
  end
end
