# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PollsController do
  render_views

  let(:user)   { Fabricate(:user) }
  let(:scopes) { 'read:statuses' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  describe 'GET #show' do
    let(:poll) { Fabricate(:poll, status: Fabricate(:status, visibility: visibility)) }

    before do
      get :show, params: { id: poll.id }
    end

    context 'when parent status is public' do
      let(:visibility) { 'public' }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when parent status is private' do
      let(:visibility) { 'private' }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
