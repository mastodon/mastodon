# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Polls::VotesController do
  render_views

  let(:user)   { Fabricate(:user) }
  let(:scopes) { 'write:statuses' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  describe 'POST #create' do
    let(:poll) { Fabricate(:poll) }

    before do
      post :create, params: { poll_id: poll.id, choices: %w(1) }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'creates a vote' do
      vote = poll.votes.where(account: user.account).first

      expect(vote).to_not be_nil
      expect(vote.choice).to eq 1
    end

    it 'updates poll tallies' do
      expect(poll.reload.cached_tallies).to eq [0, 1]
    end
  end
end
