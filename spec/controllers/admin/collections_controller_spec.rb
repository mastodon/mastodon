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
    subject { post :batch, params: { account_id: account.id, report_id: report_id, admin_collection_batch_action: { collection_ids: [collection.id, second_collection.id] } } }

    context 'with a valid report' do
      let(:report_id) { report.id }

      before do
        report.collections << collection
        report.save
      end

      it 'redirects to the report page' do
        subject
        expect(response).to redirect_to(admin_report_path(Report.last.id))
      end
    end

    context 'with an invalid report' do
      let(:report_id) { nil }

      it 'redirects to the account collections page' do
        subject
        expect(response).to redirect_to(admin_account_collections_path(account.id))
      end
    end
  end
end
