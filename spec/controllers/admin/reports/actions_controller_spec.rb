# frozen_string_literal: true

require 'rails_helper'

describe Admin::Reports::ActionsController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #preview' do
    let(:report) { Fabricate(:report) }

    before do
      post :preview, params: { report_id: report.id, action => '' }
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
    let!(:media)         { Fabricate(:media_attachment, account: target_account, status: statuses[0]) }
    let(:report)         { Fabricate(:report, target_account: target_account, status_ids: statuses.map(&:id)) }
    let(:text)           { 'hello' }

    shared_examples 'common behavior' do
      it 'closes the report' do
        expect { subject }.to change { report.reload.action_taken? }.from(false).to(true)
      end

      it 'creates a strike with the expected text' do
        expect { subject }.to change { report.target_account.strikes.count }.by(1)
        expect(report.target_account.strikes.last.text).to eq text
      end

      it 'redirects' do
        subject
        expect(response).to redirect_to(admin_reports_path)
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

        let!(:status) { Fabricate(:status, account: target_account) }
        let(:media_attached_status) { Fabricate(:status, account: target_account) }
        let!(:media_attachment) { Fabricate(:media_attachment, account: target_account, status: media_attached_status) }
        let(:media_attached_deleted_status) { Fabricate(:status, account: target_account, deleted_at: 1.day.ago) }
        let!(:media_attachment2) { Fabricate(:media_attachment, account: target_account, status: media_attached_deleted_status) }
        let(:last_media_attached_status) { Fabricate(:status, account: target_account) }
        let!(:last_media_attachment) { Fabricate(:media_attachment, account: target_account, status: last_media_attached_status) }
        let!(:last_status) { Fabricate(:status, account: target_account) }

        it_behaves_like 'common behavior'

        it 'marks the non-deleted as sensitive' do
          subject
          expect(media_attached_status.reload.sensitive).to be true
        end
      end
    end

    context 'action as submit button' do
      subject { post :create, params: { report_id: report.id, text: text, action => '' } }

      it_behaves_like 'all action types'
    end

    context 'action as submit button' do
      subject { post :create, params: { report_id: report.id, text: text, moderation_action: action } }

      it_behaves_like 'all action types'
    end
  end
end
