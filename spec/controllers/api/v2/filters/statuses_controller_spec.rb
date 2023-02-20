require 'rails_helper'

RSpec.describe Api::V2::Filters::StatusesController, type: :controller do
  render_views

  let(:user)         { Fabricate(:user) }
  let(:token)        { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:filter)       { Fabricate(:custom_filter, account: user.account) }
  let(:other_user)   { Fabricate(:user) }
  let(:other_filter) { Fabricate(:custom_filter, account: other_user.account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:scopes) { 'read:filters' }
    let!(:status_filter) { Fabricate(:custom_filter_status, custom_filter: filter) }

    it 'returns http success' do
      get :index, params: { filter_id: filter.id }
      expect(response).to have_http_status(200)
    end

    context "when trying to access another's user filters" do
      it 'returns http not found' do
        get :index, params: { filter_id: other_filter.id }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST #create' do
    let(:scopes)    { 'write:filters' }
    let(:filter_id) { filter.id }
    let!(:status)   { Fabricate(:status) }

    before do
      post :create, params: { filter_id: filter_id, status_id: status.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns a status filter' do
      json = body_as_json
      expect(json[:status_id]).to eq status.id.to_s
    end

    it 'creates a status filter' do
      filter = user.account.custom_filters.first
      expect(filter).to_not be_nil
      expect(filter.statuses.pluck(:status_id)).to eq [status.id]
    end

    context "when trying to add to another another's user filters" do
      let(:filter_id) { other_filter.id }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'GET #show' do
    let(:scopes) { 'read:filters' }
    let!(:status_filter) { Fabricate(:custom_filter_status, custom_filter: filter) }

    before do
      get :show, params: { id: status_filter.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns expected data' do
      json = body_as_json
      expect(json[:status_id]).to eq status_filter.status_id.to_s
    end

    context "when trying to access another user's filter keyword" do
      let(:status_filter) { Fabricate(:custom_filter_status, custom_filter: other_filter) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:scopes) { 'write:filters' }
    let(:status_filter) { Fabricate(:custom_filter_status, custom_filter: filter) }

    before do
      delete :destroy, params: { id: status_filter.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the filter' do
      expect { status_filter.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    context "when trying to update another user's filter keyword" do
      let(:status_filter) { Fabricate(:custom_filter_status, custom_filter: other_filter) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
