# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Account Actions' do
  describe 'POST /admin/accounts/:account_id/action' do
    before { sign_in Fabricate(:admin_user) }

    let(:account) { Fabricate :account }

    it 'gracefully handles invalid nested params' do
      post admin_account_action_path(account.id, admin_account_action: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
