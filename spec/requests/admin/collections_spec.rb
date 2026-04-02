# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Collections' do
  describe 'GET /admin/accounts/:account_id/collections/:id' do
    let(:collection) { Fabricate(:collection) }

    before do
      sign_in Fabricate(:admin_user)
    end

    it 'returns success' do
      get admin_account_collection_path(collection.account_id, collection)

      expect(response)
        .to have_http_status(200)
    end
  end
end
