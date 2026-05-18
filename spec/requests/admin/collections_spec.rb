# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Collections' do
  let(:account) { Fabricate(:account) }
  let(:other_account) { Fabricate(:account) }
  let(:collection) { Fabricate(:collection, account: account) }
  let!(:second_collection) { Fabricate(:collection, account: account) }
  let(:report) { Fabricate(:report, account: other_account, target_account: account) }

  before do
    sign_in Fabricate(:admin_user)
  end

  describe 'GET /admin/accounts/:account_id/collections/:id' do
    let(:collection) { Fabricate(:collection) }

    it 'returns success' do
      get admin_account_collection_path(collection.account_id, collection)

      expect(response)
        .to have_http_status(200)
    end
  end

  describe 'GET /admin/accounts/:account_id/collections/' do
    it 'returns http success' do
      get admin_account_collections_path(account_id: account.id, id: collection.id)
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /admin/accounts/:account_id/collections/batch' do
    subject { post batch_admin_account_collections_path(account_id: account.id, report_id: report_id, admin_collection_batch_action: { collection_ids: [collection.id, second_collection.id] }) }

    context 'with a valid report' do
      let(:report_id) { report.id }

      it 'redirects to the report page' do
        report.collections << collection
        subject
        expect(response).to redirect_to(admin_report_path(report.id))
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
