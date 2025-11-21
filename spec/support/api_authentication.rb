# frozen_string_literal: true

RSpec.shared_context 'with API authentication' do |oauth_scopes: '', user_fabricator: :user|
  let(:user)    { Fabricate(user_fabricator) }
  let(:scopes)  { oauth_scopes }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
end
