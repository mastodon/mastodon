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

    let(:accounts) { Fabricate.times(5, :account) }
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

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns the expected content from accounts requesting to follow' do
      subject

      expect(body_as_json).to match_array(expected_response)
    end

    context 'with limit param' do
      let(:params) { { limit: 2 } }

      it 'returns only the requested number of follow requests' do
        subject

        expect(body_as_json.size).to eq(params[:limit])
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

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'allows the requesting follower to follow' do
      expect { subject }.to change { follower.following?(user.account) }.from(false).to(true)
    end

    it 'returns JSON with followed_by set to true' do
      subject

      expect(body_as_json[:followed_by]).to be true
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

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'removes the follow request' do
      subject

      expect(FollowRequest.where(target_account: user.account, account: follower)).to_not exist
    end

    it 'returns JSON with followed_by set to false' do
      subject

      expect(body_as_json[:followed_by]).to be false
    end
  end
end
