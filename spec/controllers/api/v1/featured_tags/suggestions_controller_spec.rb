# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::FeaturedTags::SuggestionsController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:accounts') }
  let(:account) { Fabricate(:account, user: user) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let!(:unused_featured_tag) { Fabricate(:tag, name: 'unused_featured_tag') }
    let!(:used_tag) { Fabricate(:tag, name: 'used_tag') }
    let!(:used_featured_tag) { Fabricate(:tag, name: 'used_featured_tag') }

    before do
      _unused_tag = Fabricate(:tag, name: 'unused_tag')

      # Make relevant tags used by account
      status = Fabricate(:status, account: account)
      status.tags << used_tag
      status.tags << used_featured_tag

      # Feature the relevant tags
      Fabricate :featured_tag, account: account, name: unused_featured_tag.name
      Fabricate :featured_tag, account: account, name: used_featured_tag.name
    end

    it 'returns http success and recently used but not featured tags', :aggregate_failures do
      get :index, params: { account_id: account.id, limit: 2 }

      expect(response)
        .to have_http_status(200)
      expect(body_as_json)
        .to contain_exactly(
          include(name: used_tag.name)
        )
    end
  end
end
