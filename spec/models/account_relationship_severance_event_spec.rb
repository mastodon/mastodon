# frozen_string_literal: true

RSpec.describe AccountRelationshipSeveranceEvent do
  describe 'Associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:relationship_severance_event) }
    it { is_expected.to have_many(:severed_relationships).through(:relationship_severance_event) }
  end

  describe '#identifier' do
    subject { account_relationship_severance_event.identifier }

    let(:account_relationship_severance_event) { Fabricate.build :account_relationship_severance_event, relationship_severance_event:, created_at: DateTime.new(2026, 3, 15, 1, 2, 3) }
    let(:relationship_severance_event) { Fabricate.build :relationship_severance_event, target_name: 'host.example' }

    context 'with a hostname target and timestamp' do
      it { is_expected.to eq('host.example-2026-03-15') }
    end
  end
end
