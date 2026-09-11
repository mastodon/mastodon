# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Trends Approvals' do
  before { sign_in Fabricate(:admin_user) }

  describe 'POST /admin/accounts/:account_id/trends/approval' do
    let(:account) { Fabricate(:account, trendable: false) }

    it 'approves account to appear in trends' do
      post admin_account_trends_approval_path(account.id)

      expect(response)
        .to redirect_to(admin_account_path(account.id))
      expect(account.reload)
        .to be_trendable
    end
  end

  describe 'DELETE /admin/accounts/:account_id/trends/approval' do
    let(:account) { Fabricate(:account, trendable: true) }

    it 'rejects account from showing in trends' do
      delete admin_account_trends_approval_path(account.id)

      expect(response)
        .to redirect_to(admin_account_path(account.id))
      expect(account.reload)
        .to_not be_trendable
    end
  end
end
