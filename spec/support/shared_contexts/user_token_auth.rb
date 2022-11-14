# frozen_string_literal: true
shared_context 'user token auth' do
  let(:user_args) { {} }
  let!(:user) { Fabricate(:user, user_args) }
  let(:user_token_args) { {} }
  let(:user_token_scopes) { 'read write follow push admin:read admin:write' }
  let!(:user_token) do
    Fabricate(
      :accessible_access_token,
      user_token_args.merge(resource_owner_id: user.id, scopes: user_token_scopes)
    )
  end
  let!(:authorization) { "Bearer #{user_token.token}" }
end
