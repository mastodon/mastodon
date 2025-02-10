# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts' do
  describe 'POST /admin/accounts/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_accounts_path(form_account_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_accounts_path)
    end
  end
end
