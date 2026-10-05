# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Users SignInTokenAuthentications' do
  let(:user) { Fabricate(:user) }

  before { sign_in Fabricate(:admin_user) }

  describe 'Disabling Sign In Token for users' do
    context 'when user has been inactive for too long' do
      before { user.update(current_sign_in_at: 95.days.ago) }

      it 'disables sign in token and redirects to admin account page' do
        visit admin_account_path(user.account.id)

        expect { disable_sign_in_token }
          .to change { user.reload.suspicious_inactive_sign_in? }.to(false)
        expect(page)
          .to have_title(user.account.pretty_acct)
      end
    end

    def disable_sign_in_token
      click_on I18n.t('admin.accounts.disable_sign_in_token')
    end
  end

  describe 'Enabling Sign In Token for users' do
    context 'when user has been inactive for too long' do
      before do
        user.update(current_sign_in_at: 95.days.ago)
        user.disable_sign_in_token!
      end

      it 'enables sign in token and redirects to admin account page' do
        visit admin_account_path(user.account.id)

        expect { enable_sign_in_token }
          .to change { user.reload.suspicious_inactive_sign_in? }.to(true)
        expect(page)
          .to have_title(user.account.pretty_acct)
      end
    end

    def disable_sign_in_token
      click_on I18n.t('admin.accounts.disable_sign_in_token')
    end

    def enable_sign_in_token
      click_on I18n.t('admin.accounts.enable_sign_in_token')
    end
  end
end
