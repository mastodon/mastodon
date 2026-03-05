# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Reset' do
  it 'Resets password for account user', :inline_jobs do
    account = Fabricate :account
    sign_in admin_user
    visit admin_account_path(account.id)

    expect do
      expect { submit_reset }
        .to send_email(to: account.user.email, subject: password_change_subject)
        .and send_email(to: account.user.email, subject: reset_instructions_subject)
    end.to change(Admin::ActionLog.where(target: account.user), :count).by(1)

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
