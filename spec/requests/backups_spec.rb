# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backups' do
  include RoutingHelper

  describe 'GET backups#download' do
    let(:user) { Fabricate(:user) }
    let(:backup) { Fabricate(:backup, user: user) }

    before do
      sign_in user
    end

    it 'Downloads a user backup' do
      get download_backup_path(backup)

      expect(response).to redirect_to(backup_dump_url)
    end

    def backup_dump_url
      full_asset_url(backup.dump.url)
    end
  end
end
