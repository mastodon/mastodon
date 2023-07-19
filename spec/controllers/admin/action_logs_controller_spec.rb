# frozen_string_literal: true

require 'rails_helper'

describe Admin::ActionLogsController do
  render_views

  # Action logs typically cause issues when their targets are not in the database
  let!(:account) { Fabricate(:account) }

  let!(:orphaned_logs) do
    %w(
      Account User UserRole Report DomainBlock DomainAllow
      EmailDomainBlock UnavailableDomain Status AccountWarning
      Announcement IpBlock Instance CustomEmoji CanonicalEmailBlock Appeal
    ).map { |type| Admin::ActionLog.new(account: account, action: 'destroy', target_type: type, target_id: 1312).save! }
  end

  describe 'GET #index' do
    it 'returns 200' do
      sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin'))
      get :index, params: { page: 1 }

      expect(response).to have_http_status(200)
    end
  end
end
