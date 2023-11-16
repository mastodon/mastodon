# frozen_string_literal: true

require 'rails_helper'

describe Admin::ActionLogsController do
  render_views

  # Action logs typically cause issues when their targets are not in the database
  let!(:account) { Fabricate(:account) }

  before do
    orphaned_log_types.map do |type|
      Admin::ActionLog.new(account: account, action: 'destroy', target_type: type, target_id: 1312).save!
    end
  end

  describe 'GET #index' do
    before { sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    it 'returns 200' do
      get :index, params: { page: 1 }

      expect(response)
        .to have_http_status(200)
        .and render_template(:index)
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
