# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ServerChecksController do
  render_views

  let(:role) do
    Fabricate(:user_role, permissions_as_keys: [:administrator])
  end
  let(:user) { Fabricate(:user, role:) }

  before { sign_in(user) }

  describe 'GET #index' do
    before do
      Admin::ServerCheck.destroy_all

      Fabricate('Admin::ServerCheck', key: 'rules', status: :pending, severity: :warning)
      Fabricate('Admin::ServerCheck', key: 'sidekiq_process', status: :pending, severity: :critical)
      Fabricate('Admin::ServerCheck', key: 'software_version', status: :pending, severity: :critical, data: { reason: :urgent })
      Fabricate('Admin::ServerCheck', key: 'database_schema', status: :ok)
      Fabricate('Admin::ServerCheck', key: 'elastic_search', status: :pending, ignored: true)
      Fabricate('Admin::ServerCheck', key: 'media_privacy', status: :unprocessed)
    end

    it 'returns a list of checks' do
      get :index

      expect(response).to have_http_status(200)

      expect(response.parsed_body).to have_css('.server-checks-category', count: 5)
      expect(response.parsed_body).to have_css('.server-check__icon.warning', count: 1) # rules
      expect(response.parsed_body).to have_css('.server-check__icon.critical', count: 2) # software_version, sidekiq
      expect(response.parsed_body).to have_css('.server-check__icon.ignored', count: 1) # elastic_search
      expect(response.parsed_body).to have_css('.server-check__icon.completed', count: 1) # database_schema
      expect(response.parsed_body).to have_css('.server-check__icon.unprocessed', count: 1) # media_privacy
    end
  end
end
