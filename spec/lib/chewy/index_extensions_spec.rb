# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chewy::IndexExtensions do
  describe '.update_specification' do
    let(:indices) { Chewy.client.indices }

    before do
      allow(indices).to receive_messages(close: nil, put_settings: nil, put_mapping: nil, open: nil)
    end

    context 'when the index does not define analysis settings' do
      it 'updates mappings without sending analysis settings' do
        InstancesIndex.update_specification

        expect(indices).to have_received(:close).with(index: InstancesIndex.index_name)
        expect(indices).to_not have_received(:put_settings)
        expect(indices).to have_received(:put_mapping).with(index: InstancesIndex.index_name, body: InstancesIndex.root.mappings_hash)
        expect(indices).to have_received(:open).with(index: InstancesIndex.index_name)
      end
    end

    context 'when the index defines analysis settings' do
      it 'updates analysis settings and mappings' do
        AccountsIndex.update_specification

        expect(indices).to have_received(:close).with(index: AccountsIndex.index_name)
        expect(indices).to have_received(:put_settings).with(
          index: AccountsIndex.index_name,
          body: { settings: { analysis: AccountsIndex.settings_hash[:settings][:analysis] } }
        )
        expect(indices).to have_received(:put_mapping).with(index: AccountsIndex.index_name, body: AccountsIndex.root.mappings_hash)
        expect(indices).to have_received(:open).with(index: AccountsIndex.index_name)
      end
    end
  end
end
