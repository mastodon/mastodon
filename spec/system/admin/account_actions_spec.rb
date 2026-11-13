# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Account Actions' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in user }

  describe 'Creating a new account action on an account' do
    let(:account) { Fabricate(:account) }

    it 'creates the action and redirects to the account page with preselected warning' do
      visit new_admin_account_action_path(account_id: account.id)

      expect(page)
        .to have_title(I18n.t('admin.account_actions.title', acct: account.pretty_acct))
      expect { submit_form }.to change { account.strikes.count }.by(1)
    end

    it 'creates the action and redirects to the account page' do
      visit new_admin_account_action_path(account_id: account.id)

      select 'Limit', from: 'admin_account_action[type]'
      expect { submit_form }
        .to change { account.strikes.count }.by(1)
      expect(page)
        .to have_title(account.pretty_acct)
    end
  end

  def submit_form
    within '.actions' do
      find('input[type="submit"], button[type="submit"]').click
    end
  end
end
