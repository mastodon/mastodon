# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Accounts' do
  let(:current_user) { Fabricate(:admin_user) }

  before do
    sign_in current_user
  end

  describe 'Performing batch updates' do
    let(:unapproved_user_account) { Fabricate(:account) }
    let(:approved_user_account) { Fabricate(:account) }

    before do
      unapproved_user_account.user.update(approved: false)
      approved_user_account.user.update(approved: true)

      visit admin_accounts_path
    end

    context 'without selecting any accounts' do
      it 'displays a notice about account selection' do
        click_on button_for_suspend

        expect(page).to have_content(selection_error_text)
      end
    end

    context 'with action of `suspend`' do
      it 'suspends the account' do
        batch_checkbox_for(approved_user_account).check

        click_on button_for_suspend

        expect(approved_user_account.reload).to be_suspended
      end
    end

    context 'with action of `approve`' do
      it 'approves the account user' do
        batch_checkbox_for(unapproved_user_account).check

        click_on button_for_approve

        expect(unapproved_user_account.reload.user).to be_approved
      end
    end

    context 'with action of `reject`', :inline_jobs do
      it 'rejects and removes the account' do
        batch_checkbox_for(unapproved_user_account).check

        click_on button_for_reject

        expect { unapproved_user_account.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    def button_for_suspend
      I18n.t('admin.accounts.perform_full_suspension')
    end

    def button_for_approve
      I18n.t('admin.accounts.approve')
    end

    def button_for_reject
      I18n.t('admin.accounts.reject')
    end

    def selection_error_text
      I18n.t('admin.accounts.no_account_selected')
    end

    def batch_checkbox_for(account)
      find("#form_account_batch_account_ids_#{account.id}")
    end
  end
end
