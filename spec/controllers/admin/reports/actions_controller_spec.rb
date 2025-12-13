# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Reports::ActionsController do
  render_views

  let(:user) { Fabricate(:admin_user) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #preview' do
    let(:report) { Fabricate(:report) }

    before do
      post :preview, params: { :report_id => report.id, action => '' }
    end

    context 'when the action is "suspend"' do
      let(:action) { 'suspend' }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the action is "silence"' do
      let(:action) { 'silence' }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the action is "delete"' do
      let(:action) { 'delete' }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the action is "mark_as_sensitive"' do
      let(:action) { 'mark_as_sensitive' }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST #create' do
    let(:target_account) { Fabricate(:account) }
    let(:statuses)       { [Fabricate(:status, account: target_account), Fabricate(:status, account: target_account)] }
    let(:report)         { Fabricate(:report, target_account: target_account, status_ids: statuses.map(&:id)) }
    let(:text)           { 'hello' }
    let(:common_params) do
      { report_id: report.id, text: text }
    end

    before do
      _media = Fabricate(:media_attachment, account: target_account, status: statuses[0])
    end

    shared_examples 'common behavior' do
      it 'closes the report and redirects' do
        expect { subject }.to mark_report_action_taken.and create_target_account_strike

        expect(report.target_account.strikes.last.text).to eq text
        expect(response).to redirect_to(admin_reports_path)
      end

      context 'when text is unset' do
        let(:common_params) do
          { report_id: report.id }
        end

        it 'closes the report and redirects' do
          expect { subject }.to mark_report_action_taken.and create_target_account_strike

          expect(report.target_account.strikes.last.text).to eq ''
          expect(response).to redirect_to(admin_reports_path)
        end
      end

      def mark_report_action_taken
        change { report.reload.action_taken? }.from(false).to(true)
      end

      def create_target_account_strike
        change { report.target_account.strikes.count }.by(1)
      end
    end

    shared_examples 'all action types' do
      context 'when the action is "suspend"' do
        let(:action) { 'suspend' }

        it_behaves_like 'common behavior'

        it 'suspends the target account' do
          expect { subject }.to change { report.target_account.reload.suspended? }.from(false).to(true)
        end
      end

      context 'when the action is "silence"' do
        let(:action) { 'silence' }

        it_behaves_like 'common behavior'

        it 'suspends the target account' do
          expect { subject }.to change { report.target_account.reload.silenced? }.from(false).to(true)
        end
      end

      context 'when the action is "delete"' do
        let(:action) { 'delete' }

        it_behaves_like 'common behavior'
      end

      context 'when the action is "mark_as_sensitive"' do
        let(:action) { 'mark_as_sensitive' }
        let(:statuses) { [media_attached_status, media_attached_deleted_status] }

        let(:media_attached_status) { Fabricate(:status, account: target_account) }
        let(:media_attached_deleted_status) { Fabricate(:status, account: target_account, deleted_at: 1.day.ago) }
        let(:last_media_attached_status) { Fabricate(:status, account: target_account) }

        before do
          _last_media_attachment = Fabricate(:media_attachment, account: target_account, status: last_media_attached_status)
          _last_status = Fabricate(:status, account: target_account)
          _media_attachment = Fabricate(:media_attachment, account: target_account, status: media_attached_status)
          _media_attachment2 = Fabricate(:media_attachment, account: target_account, status: media_attached_deleted_status)
          _status = Fabricate(:status, account: target_account)
        end

        it_behaves_like 'common behavior'

        it 'marks the non-deleted as sensitive' do
          subject
          expect(media_attached_status.reload.sensitive).to be true
        end
      end

      context 'when the action is "invalid_action"' do
        let(:action) { 'invalid_action' }

        it { is_expected.to redirect_to(admin_report_path(report)) }
      end
    end

    context 'with action as submit button' do
      subject { post :create, params: common_params.merge({ action => '' }) }

      it_behaves_like 'all action types'
    end

    context 'with moderation action as an extra field' do
      subject { post :create, params: common_params.merge({ moderation_action: action }) }

      it_behaves_like 'all action types'
    end
  end
end
