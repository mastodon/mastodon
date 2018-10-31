require 'rails_helper'

describe Admin::StatusesController do
  render_views

  let(:user) { Fabricate(:user, admin: true) }
  let(:account) { Fabricate(:account) }
  let!(:status) { Fabricate(:status, account: account) }
  let(:media_attached_status) { Fabricate(:status, account: account, sensitive: !sensitive) }
  let!(:media_attachment) { Fabricate(:media_attachment, account: account, status: media_attached_status) }
  let(:sensitive) { true }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'returns http success with no media' do
      get :index, params: { account_id: account.id }

      statuses = assigns(:statuses).to_a
      expect(statuses.size).to eq 2
      expect(response).to have_http_status(200)
    end

    it 'returns http success with media' do
      get :index, params: { account_id: account.id, media: true }

      statuses = assigns(:statuses).to_a
      expect(statuses.size).to eq 1
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    subject do
      -> { post :create, params: { :account_id => account.id, action => '', :form_status_batch => { status_ids: status_ids } } }
    end

    let(:action) { 'nsfw_on' }
    let(:status_ids) { [media_attached_status.id] }

    context 'when action is nsfw_on' do
      it 'updates sensitive column' do
        is_expected.to change {
          media_attached_status.reload.sensitive
        }.from(false).to(true)
      end
    end

    context 'when action is nsfw_off' do
      let(:action) { 'nsfw_off' }
      let(:sensitive) { false }

      it 'updates sensitive column' do
        is_expected.to change {
          media_attached_status.reload.sensitive
        }.from(true).to(false)
      end
    end

    context 'when action is delete' do
      let(:action) { 'delete' }

      it 'removes a status' do
        allow(RemovalWorker).to receive(:perform_async)
        subject.call
        expect(RemovalWorker).to have_received(:perform_async).with(status_ids.first)
      end
    end

    it 'redirects to account statuses page' do
      subject.call
      expect(response).to redirect_to(admin_account_statuses_path(account.id))
    end
  end
end
