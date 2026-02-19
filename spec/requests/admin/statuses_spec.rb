# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Statuses' do
  describe 'POST /admin/accounts/:account_id/statuses/batch' do
    before { sign_in Fabricate(:admin_user) }

    let(:account) { Fabricate :account }

    it 'gracefully handles invalid nested params' do
      post batch_admin_account_statuses_path(account.id, admin_status_batch_action: 'invalid')

      expect(response)
        .to redirect_to(admin_account_statuses_path(account.id))
    end
  end
end
