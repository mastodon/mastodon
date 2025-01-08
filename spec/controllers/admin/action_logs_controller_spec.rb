# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ActionLogsController do
  render_views

  # Action logs typically cause issues when their targets are not in the database
  let!(:account) { Fabricate(:account) }

  before do
    orphaned_log_types.map do |type|
      Fabricate(:action_log, account: account, action: 'destroy', target_type: type, target_id: 1312)
    end
  end

  describe 'GET #index' do
    it 'returns 200' do
      sign_in Fabricate(:admin_user)
      get :index, params: { page: 1 }

      expect(response).to have_http_status(200)
    end
  end

  private

  def orphaned_log_types
    %w(
      Account
      AccountWarning
      Announcement
      Appeal
      CanonicalEmailBlock
      CustomEmoji
      DomainAllow
      DomainBlock
      EmailDomainBlock
      Instance
      IpBlock
      Report
      Status
      UnavailableDomain
      User
      UserRole
    )
  end
end
