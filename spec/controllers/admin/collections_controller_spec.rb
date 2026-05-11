# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CollectionsController do
  render_views

  let(:user) { Fabricate(:admin_user) }
  let(:account) { Fabricate(:account) }
  let(:other_account) { Fabricate(:account) }
  let(:collection) { Fabricate(:collection, account: account) }
  let(:second_collection) { Fabricate(:collection, account: account) }
  let(:unreported_collection) { Fabricate(:collection, account: account) }
  let(:report) { Fabricate(:report, account: other_account, target_account: account) }
  let(:collection_report) { Fabricate(:collection_report, report: report, collection: collection) }

  before do
    sign_in user, scope: :user
    second_collection
    unreported_collection
  end

  describe 'GET #index' do
    context 'with a valid account' do
      before do
        get :index, params: { account_id: account.id, id: collection.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET #show' do
    before do
      get :show, params: { account_id: account.id, id: collection.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #batch' do
    subject { post :batch, params: { account_id: account.id, report_id: report.id, admin_collection_batch_action: { collection_ids: [collection.id, second_collection.id] } } }

    before do
      report.collections << collection
      report.save
    end

    it 'redirects to the report page' do
      subject
      expect(response).to redirect_to(admin_report_path(Report.last.id))
    end
  end
end
