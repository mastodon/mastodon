# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Report Notes' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in user }

  describe 'Creating notes' do
    context 'when report is unresolved' do
      let(:report) { Fabricate(:report, action_taken_at: nil, action_taken_by_account_id: nil) }

      context 'when resolve is selected' do
        it 'creates a report note and resolves report' do
          visit admin_report_path(report)

          fill_in 'report_note_content', with: 'Report note text'
          expect { submit_form }
            .to change(ReportNote, :count).by(1)
          expect(report.reload)
            .to be_action_taken
          expect(page)
            .to have_content(success_message)
        end

        def submit_form
          click_on I18n.t('admin.reports.notes.create_and_resolve')
        end
      end

      context 'when resolve is not selected' do
        it 'creates a report note and does not resolve report' do
          visit admin_report_path(report)

          fill_in 'report_note_content', with: 'Report note text'
          expect { submit_form }
            .to change(ReportNote, :count).by(1)
          expect(report.reload)
            .to_not be_action_taken
          expect(page)
            .to have_content(success_message)
        end

        def submit_form
          click_on I18n.t('admin.reports.notes.create')
        end
      end
    end

    context 'when report is resolved' do
      let(:report) { Fabricate(:report, action_taken_at: Time.current, action_taken_by_account_id: user.account.id) }

      context 'when create_and_unresolve flag is on' do
        it 'creates a report note and unresolves report' do
          visit admin_report_path(report)

          fill_in 'report_note_content', with: 'Report note text'
          expect { submit_form }
            .to change(ReportNote, :count).by(1)
          expect(report.reload)
            .to_not be_action_taken
          expect(page)
            .to have_content(success_message)
        end

        def submit_form
          click_on I18n.t('admin.reports.notes.create_and_unresolve')
        end
      end

      context 'when create_and_unresolve flag is false' do
        it 'creates a report note and does not unresolve report' do
          visit admin_report_path(report)

          fill_in 'report_note_content', with: 'Report note text'
          expect { submit_form }
            .to change(ReportNote, :count).by(1)
          expect(report.reload)
            .to be_action_taken
          expect(page)
            .to have_content(success_message)
        end

        def submit_form
          click_on I18n.t('admin.reports.notes.create')
        end
      end
    end

    context 'when content is not valid' do
      let(:report) { Fabricate(:report) }

      it 'does not create a note' do
        visit admin_report_path(report)

        fill_in 'report_note_content', with: ''
        expect { submit_form }
          .to_not change(ReportNote, :count)
        expect(page)
          .to have_content(/error below/)
      end

      def submit_form
        click_on I18n.t('admin.reports.notes.create')
      end
    end

    def success_message
      I18n.t('admin.report_notes.created_msg')
    end
  end

  describe 'Removing notes' do
    let!(:report_note) { Fabricate(:report_note) }

    it 'deletes note' do
      visit admin_report_path(report_note.report)

      expect { delete_note }
        .to change(ReportNote, :count).by(-1)
      expect(page)
        .to have_content(I18n.t('admin.report_notes.destroyed_msg'))
    end

    def delete_note
      click_on I18n.t('admin.reports.notes.delete')
    end
  end
end
