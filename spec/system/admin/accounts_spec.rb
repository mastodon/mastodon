# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Accounts' do
  let(:current_user) { Fabricate(:admin_user) }
  let(:account) { Fabricate(:account) }

  before do
    sign_in current_user
  end

  describe 'Viewing accounts' do
    context 'with multiple pages of results' do
      let!(:older_account) { Fabricate(:account, username: 'pagination_older', created_at: 2.days.ago) }
      let!(:newer_account) { Fabricate(:account, username: 'pagination_newer', created_at: 1.day.ago) }

      around do |example|
        default_per_page = Account.default_per_page
        Account.paginates_per 1
        example.run
      ensure
        Account.paginates_per default_per_page
      end

      it 'paginates matching accounts and preserves the search' do
        visit admin_accounts_path

        fill_in 'username', with: 'pagination_'
        click_on I18n.t('admin.accounts.search')

        expect(page)
          .to have_css('table.accounts-table tr', count: 1)
          .and have_link(href: admin_account_path(newer_account.id))
          .and have_no_link(href: admin_account_path(older_account.id))

        click_on I18n.t('pagination.next')

        expect(page)
          .to have_field('username', with: 'pagination_')
          .and have_css('table.accounts-table tr', count: 1)
          .and have_link(href: admin_account_path(older_account.id))
          .and have_no_link(href: admin_account_path(newer_account.id))
      end
    end

    context 'with local accounts' do
      let(:target_user) do
        Fabricate(:user, email: 'searchable@example.com', sign_up_ip: '192.0.2.42', account_attributes: { username: 'searchable', display_name: 'Searchable person' })
      end

      it 'filters accounts using the search form' do
        target_account = target_user.account
        other_account = Fabricate(:account)

        visit admin_accounts_path

        select I18n.t('admin.accounts.location.local'), from: 'origin'
        select I18n.t('admin.accounts.moderation.active'), from: 'status'
        fill_in 'username', with: target_account.username
        fill_in 'display_name', with: target_account.display_name
        fill_in 'email', with: target_user.email
        fill_in 'ip', with: '192.0.2.42'
        click_on I18n.t('admin.accounts.search')

        expect(page)
          .to have_title(I18n.t('admin.accounts.title'))
          .and have_link(href: admin_account_path(target_account.id))
          .and have_no_link(href: admin_account_path(other_account.id))
          .and have_no_link(href: admin_account_path(current_user.account_id))
      end
    end

    context 'with remote accounts' do
      let(:account) { Fabricate(:account, domain: 'example.com') }

      it 'filters accounts by domain' do
        other_account = Fabricate(:account, domain: 'other.example')
        account

        visit admin_accounts_path

        select I18n.t('admin.accounts.location.remote'), from: 'origin'
        click_on I18n.t('admin.accounts.search')
        fill_in 'by_domain', with: account.domain
        click_on I18n.t('admin.accounts.search')

        expect(page)
          .to have_link(href: admin_account_path(account.id))
          .and have_no_link(href: admin_account_path(other_account.id))
          .and have_no_link(href: admin_account_path(current_user.account_id))
      end
    end
  end

  describe 'Viewing an account' do
    context 'with moderation notes' do
      it 'shows existing notes' do
        first_note = Fabricate(:account_moderation_note, target_account: account, content: 'Note 1 remarks')
        second_note = Fabricate(:account_moderation_note, target_account: account, content: 'Note 2 remarks')

        visit admin_account_path(account.id)

        expect(page)
          .to have_css("#account_moderation_note_#{first_note.id}", text: first_note.content)
          .and have_css("#account_moderation_note_#{second_note.id}", text: second_note.content)
      end
    end

    context 'with a remote account' do
      let(:account) { Fabricate(:account, domain: 'example.com') }

      it 'shows remote account details' do
        visit admin_account_path(account.id)

        expect(page)
          .to have_title(account.pretty_acct)
          .and have_text(account.inbox_url)
      end
    end

    context 'with a local account' do
      it 'shows local account details' do
        visit admin_account_path(account.id)

        expect(page)
          .to have_title(account.pretty_acct)
          .and have_text(account.user.email)
      end
    end

    context 'with a local account without a user' do
      let(:account) { Fabricate(:account, user: nil) }

      it 'shows the remaining account profile' do
        visit admin_account_path(account.id)

        expect(page)
          .to have_title(account.pretty_acct)
          .and have_css('.card.h-card')
      end
    end
  end

  describe 'Memorializing an account' do
    let(:account) { Fabricate(:moderator_user).account }

    it 'memorializes the account of a user with a lower role' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.memorialize') }
        .to change { account.reload.memorial? }.from(false).to(true)

      expect(page)
        .to have_current_path(admin_account_path(account.id))
        .and have_text(I18n.t('admin.accounts.memorialized_msg', username: account.acct))
        .and have_no_link(I18n.t('admin.accounts.memorialize'))
    end
  end

  describe 'Enabling an account' do
    before { account.user.disable! }

    it 'enables a disabled user' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.enable') }
        .to change { account.user.reload.disabled? }.from(true).to(false)

      expect(page)
        .to have_current_path(admin_account_path(account.id))
        .and have_text(I18n.t('admin.accounts.enabled_msg', username: account.acct))
        .and have_no_link(I18n.t('admin.accounts.enable'))
    end
  end

  describe 'Approving an account' do
    before { account.user.update!(approved: false) }

    it 'approves the pending user and logs the action' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.approve') }
        .to change { account.user.reload.approved? }.from(false).to(true)

      expect(latest_admin_action_log)
        .to have_attributes(action: eq(:approve), account_id: eq(current_user.account_id), target_id: eq(account.user.id))
      expect(page)
        .to have_current_path(admin_accounts_path(status: 'pending'))
        .and have_text(I18n.t('admin.accounts.approved_msg', username: account.acct))
    end
  end

  describe 'Rejecting an account' do
    before { account.user.update!(approved: false) }

    it 'removes the pending account and logs the action' do
      target_user_id = account.user.id
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.reject') }
        .to change { Account.exists?(account.id) }.from(true).to(false)

      expect(latest_admin_action_log)
        .to have_attributes(action: eq(:reject), account_id: eq(current_user.account_id), target_id: eq(target_user_id))
      expect(page)
        .to have_current_path(admin_accounts_path(status: 'pending'))
        .and have_text(I18n.t('admin.accounts.rejected_msg', username: account.acct))
    end
  end

  describe 'Redownloading a remote account' do
    let(:account) { Fabricate(:account, domain: 'example.com') }
    let(:resolver) { instance_double(ResolveAccountService, call: nil) }

    before { allow(ResolveAccountService).to receive(:new).and_return(resolver) }

    it 'refreshes the account through the resolver' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.redownload') }
        .to change { account.reload.last_webfingered_at }.to(nil)

      expect(resolver)
        .to have_received(:call).with(account)
      expect(page)
        .to have_current_path(admin_account_path(account.id))
        .and have_text(I18n.t('admin.accounts.redownloaded_msg', username: account.acct))
    end
  end

  describe 'Removing an avatar' do
    before { account.update!(avatar: attachment_fixture('avatar.gif')) }

    it 'removes the uploaded avatar' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.remove_avatar') }
        .to change { account.reload.avatar? }.from(true).to(false)

      expect(page)
        .to have_current_path(admin_account_path(account.id))
        .and have_text(I18n.t('admin.accounts.removed_avatar_msg', username: account.acct))
        .and have_no_link(I18n.t('admin.accounts.remove_avatar'))
    end
  end

  describe 'Unblocking an email' do
    let(:account) { Fabricate(:account, user: nil, suspended: true) }

    before { Fabricate(:canonical_email_block, reference_account: account) }

    it 'removes email blocks for an account without a user' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.unblock_email') }
        .to change { CanonicalEmailBlock.where(reference_account: account).count }.from(1).to(0)

      expect(page)
        .to have_current_path(admin_account_path(account.id))
        .and have_text(I18n.t('admin.accounts.unblocked_email_msg', username: account.acct))
        .and have_no_link(I18n.t('admin.accounts.unblock_email'))
    end
  end

  describe 'Undoing sensitive media restrictions' do
    before { account.sensitize! }

    it 'marks the account as no longer sensitized' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.undo_sensitized') }
        .to change { account.reload.sensitized? }.from(true).to(false)

      expect(page)
        .to have_current_path(admin_account_path(account.id))
        .and have_no_link(I18n.t('admin.accounts.undo_sensitized'))
        .and have_link(I18n.t('admin.accounts.sensitive'))
    end
  end

  describe 'Undoing a silence' do
    before { account.silence! }

    it 'marks the account as no longer silenced' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.undo_silenced') }
        .to change { account.reload.silenced? }.from(true).to(false)

      expect(page)
        .to have_current_path(admin_account_path(account.id))
        .and have_text(I18n.t('admin.accounts.unsilenced_msg', username: account.acct))
        .and have_no_link(I18n.t('admin.accounts.undo_silenced'))
    end
  end

  describe 'Undoing a suspension' do
    before { account.suspend! }

    it 'marks the account as no longer suspended' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.undo_suspension') }
        .to change { account.reload.suspended? }.from(true).to(false)

      expect(page)
        .to have_current_path(admin_account_path(account.id))
        .and have_text(I18n.t('admin.accounts.unsuspended_msg', username: account.acct))
        .and have_no_link(I18n.t('admin.accounts.undo_suspension'))
    end
  end

  describe 'Deleting a suspended account' do
    before { account.suspend! }

    it 'queues deletion of the account data' do
      visit admin_account_path(account.id)

      expect { click_on I18n.t('admin.accounts.delete') }
        .to change(Admin::AccountDeletionWorker.jobs, :size).by(1)

      expect(Admin::AccountDeletionWorker)
        .to have_enqueued_sidekiq_job(account.id)
      expect(page)
        .to have_current_path(admin_account_path(account.id))
        .and have_text(I18n.t('admin.accounts.destroyed_msg', username: account.acct))
    end
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

        expect(page).to have_text(selection_error_text)
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

  private

  def latest_admin_action_log
    Admin::ActionLog.last
  end
end
