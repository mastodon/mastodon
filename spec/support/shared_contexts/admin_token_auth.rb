shared_context 'admin token auth' do
  let(:admin_args) { {} }
  let(:admin) do
    Fabricate(
      :user,
      admin_args.merge(
        role: UserRole.find_by(name: 'Owner'),
        admin: true,
        moderator: true
      )
    )
  end
  # let!(:admin_account) { Fabricate(:account) }
  let(:admin_token_args) { {} }
  let(:admin_token_scopes) { 'admin:write admin:read read write' }
  let!(:admin_token) do
    Fabricate(
      :accessible_access_token,
      admin_token_args.merge(resource_owner_id: admin.id, scopes: admin_token_scopes)
    )
  end
  let!(:authorization) { "Bearer #{admin_token.token}" }
end
