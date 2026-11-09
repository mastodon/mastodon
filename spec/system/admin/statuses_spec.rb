# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Statuses' do
  let(:current_user) { Fabricate(:admin_user) }
  let(:account) { Fabricate(:account) }
  let!(:status) { Fabricate(:status, account: account, text: 'A post for moderation') }
  let(:media_attached_status) { Fabricate(:status, account: account, text: 'A post with an image') }

  before do
    Fabricate(:media_attachment, account: account, status: media_attached_status)
    sign_in current_user
  end

  describe 'Viewing account statuses' do
    it 'lists posts for the account' do
      visit admin_account_statuses_path(account.id)

      expect(page)
        .to have_title(I18n.t('admin.statuses.title', name: account.pretty_acct))
        .and have_text(status.text)
        .and have_text(media_attached_status.text)
    end

    it 'filters posts by attached media' do
      visit admin_account_statuses_path(account.id)

      click_on I18n.t('admin.statuses.with_media')

      expect(page)
        .to have_text(media_attached_status.text)
        .and have_no_text(status.text)
    end
  end

  describe 'Viewing a status' do
    before do
      status.media_attachments << Fabricate(:media_attachment, type: :image, account: account)
      status.save!
      status.snapshot!(at_time: status.created_at, rate_limit: false)
      status.update!(text: 'Hello, this is an edited post')
      status.snapshot!(rate_limit: false)
    end

    it 'shows the post contents and edit history' do
      visit admin_account_status_path(account.id, status)

      expect(page)
        .to have_title(I18n.t('admin.statuses.status_title', name: account.pretty_acct))
        .and have_text(status.text)

      within '.history' do
        expect(page)
          .to have_css('.history__entry', count: 2)
          .and have_text('A post for moderation')
          .and have_text(status.text)
          .and have_text(I18n.t('admin.statuses.original_status'))
          .and have_text(I18n.t('admin.statuses.status_changed'))
      end
    end
  end

  describe 'Performing batch updates' do
    shared_examples 'reporting a selected status' do
      it 'creates a report for the selected post and shows the report page' do
        visit admin_account_statuses_path(account.id)

        batch_checkbox_for(media_attached_status).check

        expect { click_on button_for_report }
          .to change(Report, :count).by(1)

        report = Report.last
        expect(report)
          .to have_attributes(
            target_account_id: eq(account.id),
            status_ids: eq([media_attached_status.id])
          )
        expect(page)
          .to have_current_path(admin_report_path(report))
          .and have_text(media_attached_status.text)
      end
    end

    context 'without selecting any records' do
      it 'displays a notice about selection' do
        visit admin_account_statuses_path(account.id)

        click_on button_for_report

        expect(page).to have_text(selection_error_text)
      end
    end

    context 'with a selected status' do
      it_behaves_like 'reporting a selected status'
    end

    context 'when the moderator is blocked by the author' do
      before { account.block!(current_user.account) }

      it_behaves_like 'reporting a selected status'
    end

    def button_for_report
      I18n.t('admin.statuses.batch.report')
    end

    def selection_error_text
      I18n.t('admin.statuses.no_status_selected')
    end

    def batch_checkbox_for(status)
      find("#admin_status_batch_action_status_ids_#{status.id}")
    end
  end
end
