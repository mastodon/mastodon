# frozen_string_literal: true

require 'rails_helper'

describe REST::AccountSerializer do
  subject { serialized_record_json(account, described_class) }

  let(:role)    { Fabricate(:user_role, name: 'Fancy User', highlighted: true) }
  let(:user)    { Fabricate(:user, role: role) }
  let(:account) { user.account }

  context 'when the account is suspended' do
    before do
      account.suspend!
    end

    it 'returns empty roles' do
      expect(subject['roles']).to eq []
    end
  end

  context 'when the account has a highlighted role' do
    let(:role) { Fabricate(:user_role, name: 'Fancy User', highlighted: true) }

    it 'returns the expected role' do
      expect(subject['roles'].first).to include({ 'name' => 'Fancy User' })
    end

    it 'does not expose the roles permissions' do
      expect(subject['roles'].first).to_not include({ 'permissions' => role.computed_permissions.to_s })
    end
  end

  context 'when the account has a non-highlighted role' do
    let(:role) { Fabricate(:user_role, name: 'Fancy User', highlighted: false) }

    it 'returns empty roles' do
      expect(subject['roles']).to eq []
    end
  end

  context 'when the account is memorialized' do
    before do
      account.memorialize!
    end

    it 'marks it as such' do
      expect(subject['memorial']).to be true
    end
  end
end
