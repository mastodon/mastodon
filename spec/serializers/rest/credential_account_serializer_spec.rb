# frozen_string_literal: true

require 'rails_helper'

describe REST::CredentialAccountSerializer do
  subject { serialized_record_json(account, described_class) }

  let(:role)    { Fabricate(:user_role, name: 'Fancy User') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:account) { user.account }

  context 'when the account has a role' do
    it 'returns the expected role' do
      expect(subject['roles'].first).to include({ 'name' => 'Fancy User' })
    end

    it 'exposes the role permissions' do
      expect(subject['roles'].first).to include({ 'permissions' => role.computed_permissions.to_s })
    end
  end
end
