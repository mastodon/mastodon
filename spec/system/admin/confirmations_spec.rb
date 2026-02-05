# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Confirmations' do
  before { sign_in Fabricate(:admin_user) }

  describe 'Confirming a user' do
    let!(:user) { Fabricate :user, confirmed_at: nil }

    it 'changes user to confirmed and returns to accounts page' do
      # Go to accounts listing page
      visit admin_accounts_path
      expect(page)
        .to have_title(I18n.t('admin.accounts.title'))

      # Go to account page
      click_on user.account.username

      # Click to confirm
      expect { click_on I18n.t('admin.accounts.confirm') }
        .to change(Admin::ActionLog.where(action: 'confirm'), :count).by(1)
      expect(page)
        .to have_title(I18n.t('admin.accounts.title'))
      expect(user.reload)
        .to be_confirmed
    end
  end

  describe 'Resending a confirmation email', :inline_jobs do
    let!(:user) { Fabricate(:user, confirmed_at: confirmed_at) }

    context 'when email is not confirmed' do
      let(:confirmed_at) { nil }

      it 'resends the confirmation mail' do
        visit admin_account_path(id: user.account.id)

        emails = capture_emails { resend_confirmation }
        expect(page)
          .to have_title(I18n.t('admin.accounts.title'))
          .and have_content(I18n.t('admin.accounts.resend_confirmation.success'))

        expect(emails.first)
          .to be_present
          .and deliver_to(user.email)
      end
    end

    def resend_confirmation
      click_on I18n.t('admin.accounts.resend_confirmation.send')
    end
  end
end
