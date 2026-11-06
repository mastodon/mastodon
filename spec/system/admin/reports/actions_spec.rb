# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Report Actions' do
  let(:user) { Fabricate(:admin_user) }
  let(:target_account) { Fabricate(:account) }
  let(:statuses) { Fabricate.times(2, :status, account: target_account) }
  let(:report) { Fabricate(:report, target_account: target_account, status_ids: statuses.map(&:id)) }
  let(:text) { 'Please follow the server rules' }

  before do
    Fabricate(:media_attachment, account: target_account, status: statuses.first)
    sign_in user
  end

  shared_examples 'confirming a report action' do
    it 'previews the action, resolves the report, and records a strike' do
      visit admin_report_path(report)

      click_on action_button

      expect(page)
        .to have_title(I18n.t('admin.reports.confirm_action', acct: target_account.acct))
        .and have_field('text')
      expect(report.reload)
        .to_not be_action_taken
      expect(target_account.strikes)
        .to be_empty

      fill_in 'text', with: text

      expect { click_on I18n.t('admin.reports.confirm') }
        .to change { report.reload.action_taken? }.from(false).to(true)
        .and(change { target_account.strikes.count }.by(1))
        .and(action_effect)

      expect(target_account.strikes.last.text)
        .to eq(text)
      expect(page)
        .to have_current_path(admin_reports_path)
        .and have_text(I18n.t('admin.reports.processed_msg', id: report.id))
    end
  end

  shared_examples 'a report action' do
    it_behaves_like 'confirming a report action'

    context 'without warning text' do
      let(:text) { '' }

      it_behaves_like 'confirming a report action'
    end
  end

  describe 'Suspending the reported account' do
    let(:action_button) { I18n.t('admin.accounts.suspend') }
    let(:action_effect) { change { target_account.reload.suspended? }.from(false).to(true) }

    it_behaves_like 'a report action'
  end

  describe 'Silencing the reported account' do
    let(:action_button) { I18n.t('admin.accounts.silence') }
    let(:action_effect) { change { target_account.reload.silenced? }.from(false).to(true) }

    it_behaves_like 'a report action'
  end

  describe 'Deleting reported posts' do
    let(:action_button) { I18n.t('admin.reports.delete_and_resolve') }
    let(:action_effect) { change { statuses.map { |status| status.reload.discarded? } }.from([false, false]).to([true, true]) }

    it_behaves_like 'a report action'
  end

  describe 'Marking reported posts as sensitive' do
    let(:action_button) { I18n.t('admin.reports.mark_as_sensitive') }
    let(:statuses) { [media_attached_status, deleted_status] }
    let(:media_attached_status) { Fabricate(:status, account: target_account) }
    let(:deleted_status) { Fabricate(:status, account: target_account, deleted_at: 1.day.ago) }
    let(:unreported_status) { Fabricate(:status, account: target_account) }
    let(:action_effect) do
      change { media_attached_status.reload.sensitive? }.from(false).to(true)
        .and(not_change { deleted_status.reload.sensitive? })
        .and(not_change { unreported_status.reload.sensitive? })
    end

    before do
      Fabricate(:media_attachment, account: target_account, status: deleted_status)
      Fabricate(:media_attachment, account: target_account, status: unreported_status)
    end

    it_behaves_like 'a report action'
  end
end
