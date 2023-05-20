# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/v1/accounts/{account_id}' do
  it 'returns account entity as 200 OK' do
    account = Fabricate(:account)

    get "/api/v1/accounts/#{account.id}"

    aggregate_failures do
      expect(response).to have_http_status(200)
      expect(body_as_json[:id]).to eq(account.id.to_s)
    end
  end
end
