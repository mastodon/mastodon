# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Change Emails' do
  let(:admin) { Fabricate(:admin_user) }

  before { sign_in admin }

  describe 'Changing the email address for a user', :inline_jobs do
    let(:user) { Fabricate :user }

    it 'updates user details and sends email' do
      visit admin_account_change_email_path(user.account.id)
      expect(page)
        .to have_title(I18n.t('admin.accounts.change_email.title', username: user.account.username))

      fill_in 'user_unconfirmed_email', with: 'test@host.example'
      emails = capture_emails { process_change_email }
      expect(emails.first)
        .to be_present
        .and(deliver_to('test@host.example'))
        .and(have_subject(/Confirm email/))
      expect(page)
        .to have_title(user.account.pretty_acct)
    end

    def process_change_email
      expect { click_on I18n.t('admin.accounts.change_email.submit') }
        .to not_change { user.reload.email }
        .and(change { user.reload.unconfirmed_email }.to('test@host.example'))
        .and(change { user.reload.confirmation_token }.from(nil).to(be_present))
    end
  end
end
