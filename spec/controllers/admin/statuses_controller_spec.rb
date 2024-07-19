# frozen_string_literal: true

require 'rails_helper'

describe Admin::StatusesController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
  let(:account) { Fabricate(:account) }
  let!(:status) { Fabricate(:status, account: account) }
  let(:media_attached_status) { Fabricate(:status, account: account, sensitive: !sensitive) }
  let(:last_media_attached_status) { Fabricate(:status, account: account, sensitive: !sensitive) }
  let(:sensitive) { true }

  before do
    _last_media_attachment = Fabricate(:media_attachment, account: account, status: last_media_attached_status)
    _last_status = Fabricate(:status, account: account)
    _media_attachment = Fabricate(:media_attachment, account: account, status: media_attached_status)

    sign_in user, scope: :user
  end

  describe 'GET #index' do
    context 'with a valid account' do
      before do
        get :index, params: { account_id: account.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when filtering by media' do
      before do
        get :index, params: { account_id: account.id, media: true }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET #show' do
    before do
      status.media_attachments << Fabricate(:media_attachment, type: :image, account: status.account)
      status.save!
      status.snapshot!(at_time: status.created_at, rate_limit: false)
      status.update!(text: 'Hello, this is an edited post')
      status.snapshot!(rate_limit: false)
      get :show, params: { account_id: account.id, id: status.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #batch' do
    subject { post :batch, params: { :account_id => account.id, action => '', :admin_status_batch_action => { status_ids: status_ids } } }

    let(:status_ids) { [media_attached_status.id] }

    shared_examples 'when action is report' do
      let(:action) { 'report' }

      it 'creates a report and redirects to report page' do
        subject

        expect(Report.last)
          .to have_attributes(
            target_account_id: eq(account.id),
            status_ids: eq(status_ids)
          )

        expect(response).to redirect_to(admin_report_path(Report.last.id))
      end
    end

    it_behaves_like 'when action is report'

    context 'when the moderator is blocked by the author' do
      before do
        account.block!(user.account)
      end

      it_behaves_like 'when action is report'
    end
  end
end
