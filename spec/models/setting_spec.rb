# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Setting do
  describe '#to_param' do
    let(:setting) { Fabricate(:setting, var: var) }
    let(:var)     { 'var' }

    it 'returns setting.var' do
      expect(setting.to_param).to eq var
    end
  end

  describe '.[]' do
    let(:key)         { 'key' }
    let(:cache_key)   { 'cache-key' }
    let(:cache_value) { 'cache-value' }

    before do
      allow(described_class).to receive(:cache_key).with(key).and_return(cache_key)
    end

    context 'when Rails.cache does not exists' do
      before do
        allow(described_class).to receive(:object).with(key).and_return(object)
        allow(described_class).to receive(:default_settings).and_return(default_settings)

        Fabricate(:setting, var: key, value: nil)

        Rails.cache.delete(cache_key)
      end

      let(:object)           { nil }
      let(:default_value)    { 'default_value' }
      let(:default_settings) { { key => default_value } }

      it 'calls Setting.object' do
        allow(described_class).to receive(:object).with(key)

        described_class[key]

        expect(described_class).to have_received(:object).with(key)
      end

      context 'when Setting.object returns truthy' do
        let(:object) { db_val }
        let(:db_val) { instance_double(described_class, value: 'db_val') }
        let(:default_value) { 'default_value' }

        it 'returns db_val.value' do
          expect(described_class[key]).to be db_val.value
        end
      end

      context 'when Setting.object returns falsey' do
        let(:object) { nil }

        it 'returns default_settings[key]' do
          expect(described_class[key]).to be default_settings[key]
        end
      end
    end

    context 'when Rails.cache exists' do
      before do
        Rails.cache.write(cache_key, cache_value)
      end

      it 'does not query the database' do
        callback = double
        allow(callback).to receive(:call)
        ActiveSupport::Notifications.subscribed callback, 'sql.active_record' do
          described_class[key]
        end
        expect(callback).to_not have_received(:call)
      end

      it 'returns the cached value' do
        expect(described_class[key]).to eq cache_value
      end
    end
  end
end
