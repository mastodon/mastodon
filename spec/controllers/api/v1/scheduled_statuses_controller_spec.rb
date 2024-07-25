# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ScheduledStatusesController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:statuses') }
  let(:account) { Fabricate(:account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  context 'with an application token' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil, scopes: 'read:statuses') }

    it 'returns http unprocessable entity' do
      get :index

      expect(response)
        .to have_http_status(422)
    end
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(200)
    end
  end
end
