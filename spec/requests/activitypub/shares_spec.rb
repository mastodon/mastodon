# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivityPub Shares' do
  let(:account) { Fabricate(:account) }
  let(:status) { Fabricate :status, account: account }

  before { Fabricate :status, reblog: status }

  describe 'GET /accounts/:account_username/statuses/:status_id/shares' do
    it 'returns http success and activity json types and correct items count' do
      get account_status_shares_path(account, status)

      expect(response)
        .to have_http_status(200)
      expect(response.media_type)
        .to eq 'application/activity+json'

      expect(response.parsed_body)
        .to include(type: 'Collection')
        .and include(totalItems: 1)
    end
  end
end
