# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Follow requests' do
  let(:user)     { Fabricate(:user, account_attributes: { locked: true }) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'read:follows write:follows' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/follow_requests' do
    subject do
      get '/api/v1/follow_requests', headers: headers, params: params
    end

    let(:accounts) { Fabricate.times(2, :account) }
    let(:params)   { {} }

    let(:expected_response) do
      accounts.map do |account|
        a_hash_including(
          id: account.id.to_s,
          username: account.username,
          acct: account.acct
        )
      end
    end

    before do
      accounts.each { |account| FollowService.new.call(account, user.account) }
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:follows'

    it 'returns the expected content from accounts requesting to follow', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to match_array(expected_response)
    end

    context 'with limit param' do
      let(:params) { { limit: 1 } }

      it 'returns only the requested number of follow requests' do
        subject

        expect(response.parsed_body.size).to eq(params[:limit])
      end
    end
  end

  describe 'POST /api/v1/follow_requests/:account_id/authorize' do
    subject do
      post "/api/v1/follow_requests/#{follower.id}/authorize", headers: headers
    end

    let(:follower) { Fabricate(:account) }

    before do
      FollowService.new.call(follower, user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:follows'

    it 'allows the requesting follower to follow', :aggregate_failures do
      expect { subject }.to change { follower.following?(user.account) }.from(false).to(true)
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body[:followed_by]).to be true
    end
  end

  describe 'POST /api/v1/follow_requests/:account_id/reject' do
    subject do
      post "/api/v1/follow_requests/#{follower.id}/reject", headers: headers
    end

    let(:follower) { Fabricate(:account) }

    before do
      FollowService.new.call(follower, user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:follows'

    it 'removes the follow request', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(FollowRequest.where(target_account: user.account, account: follower)).to_not exist
      expect(response.parsed_body[:followed_by]).to be false
    end
  end
end
