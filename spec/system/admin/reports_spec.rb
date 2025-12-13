# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Reports' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in(user) }

  describe 'Viewing existing reports' do
    let!(:unresolved_report) { Fabricate(:report, action_taken_at: nil, comment: 'First report') }
    let!(:resolved_report) { Fabricate(:report, action_taken_at: Time.now.utc, comment: 'Second report') }
    let!(:report_note) { Fabricate :report_note, report: resolved_report, content: 'Note about resolved report' }

    it 'Shows basic report details' do
      visit admin_reports_path

      expect(page)
        .to have_content(unresolved_report.comment)
        .and have_no_content(resolved_report.comment)

      click_on I18n.t('admin.reports.resolved')
      expect(page)
        .to have_content(resolved_report.comment)
        .and have_no_content(unresolved_report.comment)

      click_on resolved_report.comment
      expect(page)
        .to have_title(I18n.t('admin.reports.report', id: resolved_report.id))
        .and have_content(resolved_report.comment)
        .and have_content(report_note.content)
    end
  end

  describe 'Resolving reports' do
    let!(:report) { Fabricate :report }

    it 'resolves an open report' do
      visit admin_report_path(report)
      within '.content__heading__actions' do
        click_on I18n.t('admin.reports.mark_as_resolved')
      end

      expect(page)
        .to have_title(I18n.t('admin.reports.title'))
        .and have_content(I18n.t('admin.reports.resolved_msg'))

      report.reload
      expect(report.action_taken_by_account)
        .to eq user.account
      expect(report)
        .to be_action_taken
      expect(last_action_log.target)
        .to eq(report)
    end
  end

  describe 'Reopening reports' do
    let!(:report) { Fabricate :report, action_taken_at: 3.days.ago }

    it 'reopens a resolved report' do
      visit admin_report_path(report)
      within '.content__heading__actions' do
        click_on I18n.t('admin.reports.mark_as_unresolved')
      end

      expect(page)
        .to have_title(I18n.t('admin.reports.report', id: report.id))

      report.reload
      expect(report.action_taken_by_account)
        .to be_nil
      expect(report)
        .to_not be_action_taken
      expect(last_action_log.target)
        .to eq(report)
    end
  end

  describe 'Assigning reports' do
    let!(:report) { Fabricate :report }

    it 'assigns report to user and then unassigns' do
      visit admin_report_path(report)

      click_on I18n.t('admin.reports.assign_to_self')

      expect(page)
        .to have_title(I18n.t('admin.reports.report', id: report.id))
      report.reload
      expect(report.assigned_account)
        .to eq user.account
      expect(last_action_log.target)
        .to eq(report)

      click_on I18n.t('admin.reports.unassign')
      expect(page)
        .to have_title(I18n.t('admin.reports.report', id: report.id))
      report.reload
      expect(report.assigned_account)
        .to be_nil
      expect(last_action_log.target)
        .to eq(report)
    end
  end

  private

  def last_action_log
    Admin::ActionLog.last
  end
end
