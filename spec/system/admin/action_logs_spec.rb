# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Action Logs' do
  # Action logs typically cause issues when their targets are not in the database
  let!(:account) { Fabricate(:account) }

  before do
    populate_action_logs
    sign_in Fabricate(:admin_user)
  end

  describe 'Viewing action logs' do
    it 'shows page with action logs listed' do
      visit admin_action_logs_path

      expect(page)
        .to have_title(I18n.t('admin.action_logs.title'))
        .and have_css('.log-entry')
    end
  end

  private

  def populate_action_logs
    orphaned_log_types.map do |type|
      Fabricate(:action_log, account: account, action: 'destroy', target_type: type, target_id: 1312)
    end
  end

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
