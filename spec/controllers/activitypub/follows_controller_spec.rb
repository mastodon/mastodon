# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::FollowsController, type: :controller do
  let(:follow_request) { Fabricate(:follow_request, account: account) }

  render_views

  context 'with local account' do
    let(:account) { Fabricate(:account, domain: nil) }

    it 'returns follow request' do
      signed_request = Request.new(:get, account_follow_url(account, follow_request))
      signed_request.on_behalf_of(follow_request.target_account)
      request.headers.merge! signed_request.headers

      get :show, params: { id: follow_request, account_username: account.username }

      expect(body_as_json[:id]).to eq ActivityPub::TagManager.instance.uri_for(follow_request)
      expect(response).to have_http_status :success
    end

    it 'returns http 404 without signature' do
      get :show, params: { id: follow_request, account_username: account.username }
      expect(response).to have_http_status 404
    end
  end

  context 'with remote account' do
    let(:account) { Fabricate(:account, domain: Faker::Internet.domain_name) }

    it 'returns http 404' do
      signed_request = Request.new(:get, account_follow_url(account, follow_request))
      signed_request.on_behalf_of(follow_request.target_account)
      request.headers.merge! signed_request.headers

      get :show, params: { id: follow_request, account_username: account.username }

      expect(response).to have_http_status 404
    end
  end
end
