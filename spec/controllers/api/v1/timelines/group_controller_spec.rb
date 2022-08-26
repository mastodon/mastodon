# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Timelines::GroupController do
  render_views

  let(:user) { Fabricate(:user) }
  let(:group) { Fabricate(:group) }
  let!(:membership) { Fabricate(:group_membership, account: user.account, group: group) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  context 'with a user context' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:groups') }

    describe 'GET #show' do
      before do
        other_membership = Fabricate(:group_membership, group: group)
        PostStatusService.new.call(other_membership.account, text: 'New status for group timeline.', group: group, visibility: 'group')
      end

      it 'returns http success' do
        get :show, params: { id: group.id }
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'without a user context' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil, scopes: 'read') }

    describe 'GET #show' do
      it 'returns http success' do
        get :show, params: { id: group.id }
        expect(response).to have_http_status(200)
      end
    end
  end
end
