require 'rails_helper'

describe Admin::Reports::ActionsController do
  render_views

  let(:user) { Fabricate(:user, role: 'moderator') }
  let(:account) { Fabricate(:account) }
  let!(:status) { Fabricate(:status, account: account) }
  let(:media_attached_status) { Fabricate(:status, account: account) }
  let!(:media_attachment) { Fabricate(:media_attachment, account: account, status: media_attached_status) }
  let(:media_attached_deleted_status) { Fabricate(:status, account: account, deleted_at: 1.day.ago) }
  let!(:media_attachment2) { Fabricate(:media_attachment, account: account, status: media_attached_deleted_status) }
  let(:last_media_attached_status) { Fabricate(:status, account: account) }
  let!(:last_media_attachment) { Fabricate(:media_attachment, account: account, status: last_media_attached_status) }
  let!(:last_status) { Fabricate(:status, account: account) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #create' do
    let(:report) { Fabricate(:report, status_ids: status_ids, account: user.account, target_account: account) }
    let(:status_ids) { [media_attached_status.id, media_attached_deleted_status.id] }

    before do
      post :create, params: { report_id: report.id, action => '' }
    end

    context 'when action is mark_as_sensitive' do

      let(:action) { 'mark_as_sensitive' }

      it 'resolves the report' do
        expect(report.reload.action_taken_at).to_not be_nil
      end

      it 'marks the non-deleted as sensitive' do
        expect(media_attached_status.reload.sensitive).to eq true
      end
    end
  end
end
