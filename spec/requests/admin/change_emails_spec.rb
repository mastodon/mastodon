# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Account Change Email' do
  describe 'PUT /admin/accounts/:account_id/change_email' do
    before { sign_in Fabricate(:admin_user) }

    let(:account) { Fabricate :account }

    it 'gracefully handles invalid nested params' do
      put admin_account_change_email_path(account.id, user: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
