# frozen_string_literal: true

require 'rails_helper'

describe Admin::ReportNotesController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #create' do
    subject { post :create, params: params }

    let(:report) { Fabricate(:report, action_taken_at: action_taken, action_taken_by_account_id: account_id) }

    context 'when parameter is valid' do
      context 'when report is unsolved' do
        let(:action_taken) { nil }
        let(:account_id) { nil }

        context 'when create_and_resolve flag is on' do
          let(:params) { { report_note: { report_id: report.id, content: 'test content' }, create_and_resolve: nil } }

          it 'creates a report note and resolves report' do
            expect { subject }.to change(ReportNote, :count).by(1)
            expect(report.reload).to be_action_taken
            expect(response).to redirect_to admin_reports_path
          end
        end

        context 'when create_and_resolve flag is false' do
          let(:params) { { report_note: { report_id: report.id, content: 'test content' } } }

          it 'creates a report note and does not resolve report' do
            expect { subject }.to change(ReportNote, :count).by(1)
            expect(report.reload).to_not be_action_taken
            expect(response).to redirect_to admin_report_path(report)
          end
        end
      end

      context 'when report is resolved' do
        let(:action_taken) { Time.now.utc }
        let(:account_id) { user.account.id }

        context 'when create_and_unresolve flag is on' do
          let(:params) { { report_note: { report_id: report.id, content: 'test content' }, create_and_unresolve: nil } }

          it 'creates a report note and unresolves report' do
            expect { subject }.to change(ReportNote, :count).by(1)
            expect(report.reload).to_not be_action_taken
            expect(response).to redirect_to admin_report_path(report)
          end
        end

        context 'when create_and_unresolve flag is false' do
          let(:params) { { report_note: { report_id: report.id, content: 'test content' } } }

          it 'creates a report note and does not unresolve report' do
            expect { subject }.to change(ReportNote, :count).by(1)
            expect(report.reload).to be_action_taken
            expect(response).to redirect_to admin_report_path(report)
          end
        end
      end
    end

    context 'when content is too short' do
      let(:params) { { report_note: { report_id: report.id, content: '' } } }
      let(:action_taken) { nil }
      let(:account_id) { nil }

      it 'renders admin/reports/show' do
        expect { subject }.to_not change(ReportNote, :count)
        expect(subject).to render_template 'admin/reports/show'
      end
    end

    context 'when content is too long' do
      let(:params) { { report_note: { report_id: report.id, content: 'test' * ReportNote::CONTENT_SIZE_LIMIT } } }
      let(:action_taken) { nil }
      let(:account_id) { nil }

      it 'renders admin/reports/show' do
        expect { subject }.to_not change(ReportNote, :count)
        expect(subject).to render_template 'admin/reports/show'
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: report_note.id } }

    let!(:report_note) { Fabricate(:report_note) }

    it 'deletes note' do
      expect { subject }.to change(ReportNote, :count).by(-1)
      expect(response).to redirect_to admin_report_path(report_note.report)
    end
  end
end
