# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelationshipSeveranceEvent do
  let(:local_account)  { Fabricate(:account) }
  let(:remote_account) { Fabricate(:account, domain: 'example.com') }
  let(:event)          { Fabricate(:relationship_severance_event) }

  describe '#import_from_active_follows!' do
    before do
      local_account.follow!(remote_account)
    end

    it 'imports the follow relationships with the expected direction' do
      event.import_from_active_follows!(local_account.active_relationships)

      relationships = event.severed_relationships.to_a
      expect(relationships.size).to eq 1
      expect(relationships[0].account).to eq local_account
      expect(relationships[0].target_account).to eq remote_account
    end
  end

  describe '#import_from_passive_follows!' do
    before do
      remote_account.follow!(local_account)
    end

    it 'imports the follow relationships with the expected direction' do
      event.import_from_passive_follows!(local_account.passive_relationships)

      relationships = event.severed_relationships.to_a
      expect(relationships.size).to eq 1
      expect(relationships[0].account).to eq remote_account
      expect(relationships[0].target_account).to eq local_account
    end
  end

  describe '#affected_local_accounts' do
    before do
      event.severed_relationships.create!(local_account: local_account, remote_account: remote_account, direction: :active)
    end

    it 'correctly lists local accounts' do
      expect(event.affected_local_accounts.to_a).to contain_exactly(local_account)
    end
  end
end
