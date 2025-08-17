# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Reset' do
  it 'Resets password for account user', :inline_jobs do
    account = Fabricate :account
    sign_in admin_user
    visit admin_account_path(account.id)

    emails = capture_emails do
      expect { submit_reset }
        .to change(Admin::ActionLog.where(target: account.user), :count).by(1)
    end

    expect(emails.first)
      .to be_present
      .and(deliver_to(account.user.email))
      .and(have_subject(password_change_subject))

    expect(emails.last)
      .to be_present
      .and(deliver_to(account.user.email))
      .and(have_subject(reset_instructions_subject))

    expect(page)
      .to have_content(account.username)
  end

  def admin_user
    Fabricate(:admin_user)
  end

  def submit_reset
    click_on I18n.t('admin.accounts.reset_password')
  end

  def password_change_subject
    I18n.t('devise.mailer.password_change.subject')
  end

  def reset_instructions_subject
    I18n.t('devise.mailer.reset_password_instructions.subject')
  end
end
