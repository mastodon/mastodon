# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseHelper do
  context 'when a replica is enabled' do
    around do |example|
      ClimateControl.modify REPLICA_DB_NAME: 'prod-relay-quantum-tunnel-mirror' do
        example.run
      end
    end

    before { allow(ApplicationRecord).to receive(:connected_to) }

    describe '#with_read_replica' do
      it 'uses the replica for connections' do
        helper.with_read_replica { _x = 1 }

        expect(ApplicationRecord)
          .to have_received(:connected_to).with(role: :reading, prevent_writes: true)
      end
    end

    describe '#with_primary' do
      it 'uses the primary for connections' do
        helper.with_primary { _x = 1 }

        expect(ApplicationRecord)
          .to have_received(:connected_to).with(role: :writing)
      end
    end
  end

  context 'when a replica is not enabled' do
    around do |example|
      ClimateControl.modify REPLICA_DB_NAME: nil do
        example.run
      end
    end

    before { allow(ApplicationRecord).to receive(:connected_to) }

    describe '#with_read_replica' do
      it 'does not use the replica for connections' do
        helper.with_read_replica { _x = 1 }

        expect(ApplicationRecord)
          .to_not have_received(:connected_to).with(role: :reading, prevent_writes: true)
      end
    end

    describe '#with_primary' do
      it 'does not use the primary for connections' do
        helper.with_primary { _x = 1 }

        expect(ApplicationRecord)
          .to_not have_received(:connected_to).with(role: :writing)
      end
    end
  end
end
