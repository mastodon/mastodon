# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Featured Tags Suggestions API' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:accounts' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account) { Fabricate(:account, user: user) }

  describe 'GET /api/v1/featured_tags/suggestions' do
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

    it 'returns http success and recently used but not featured tags' do
      get '/api/v1/featured_tags/suggestions', params: { limit: 2 }, headers: headers

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to contain_exactly(
          include(name: used_tag.name)
        )
    end
  end
end
