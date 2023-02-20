# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe '#to_param' do
    let(:setting) { Fabricate(:setting, var: var) }
    let(:var)     { 'var' }

    it 'returns setting.var' do
      expect(setting.to_param).to eq var
    end
  end

  describe '.[]' do
    before do
      allow(described_class).to receive(:rails_initialized?).and_return(rails_initialized)
    end

    let(:key) { 'key' }

    context 'rails_initialized? is falsey' do
      let(:rails_initialized) { false }

      it 'calls RailsSettings::Base#[]' do
        expect(RailsSettings::Base).to receive(:[]).with(key)
        described_class[key]
      end
    end

    context 'rails_initialized? is truthy' do
      before do
        allow(RailsSettings::Base).to receive(:cache_key).with(key, nil).and_return(cache_key)
      end

      let(:rails_initialized) { true }
      let(:cache_key)         { 'cache-key' }
      let(:cache_value)       { 'cache-value' }

      it 'calls not RailsSettings::Base#[]' do
        expect(RailsSettings::Base).to_not receive(:[]).with(key)
        described_class[key]
      end

      context 'Rails.cache does not exists' do
        before do
          allow(RailsSettings::Settings).to receive(:object).with(key).and_return(object)
          allow(described_class).to receive(:default_settings).and_return(default_settings)
          allow_any_instance_of(Settings::ScopedSettings).to receive(:thing_scoped).and_return(records)
          Rails.cache.delete(cache_key)
        end

        let(:object)           { nil }
        let(:default_value)    { 'default_value' }
        let(:default_settings) { { key => default_value } }
        let(:records)          { [Fabricate(:setting, var: key, value: nil)] }

        it 'calls RailsSettings::Settings.object' do
          expect(RailsSettings::Settings).to receive(:object).with(key)
          described_class[key]
        end

        context 'RailsSettings::Settings.object returns truthy' do
          let(:object) { db_val }
          let(:db_val) { double(value: 'db_val') }

          context 'default_value is a Hash' do
            let(:default_value) { { default_value: 'default_value' } }

            it 'calls default_value.with_indifferent_access.merge!' do
              expect(default_value).to receive_message_chain(:with_indifferent_access, :merge!)
                .with(db_val.value)

              described_class[key]
            end
          end

          context 'default_value is not a Hash' do
            let(:default_value) { 'default_value' }

            it 'returns db_val.value' do
              expect(described_class[key]).to be db_val.value
            end
          end
        end

        context 'RailsSettings::Settings.object returns falsey' do
          let(:object) { nil }

          it 'returns default_settings[key]' do
            expect(described_class[key]).to be default_settings[key]
          end
        end
      end

      context 'Rails.cache exists' do
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

  describe '.all_as_records' do
    before do
      allow_any_instance_of(Settings::ScopedSettings).to receive(:thing_scoped).and_return(records)
      allow(described_class).to receive(:default_settings).and_return(default_settings)
    end

    let(:key)              { 'key' }
    let(:default_value)    { 'default_value' }
    let(:default_settings) { { key => default_value } }
    let(:original_setting) { Fabricate(:setting, var: key, value: nil) }
    let(:records)          { [original_setting] }

    it 'returns a Hash' do
      expect(described_class.all_as_records).to be_a Hash
    end

    context 'records includes Setting with var as the key' do
      let(:records) { [original_setting] }

      it 'includes the original Setting' do
        setting = described_class.all_as_records[key]
        expect(setting).to eq original_setting
      end
    end

    context 'records includes nothing' do
      let(:records) { [] }

      context 'default_value is not a Hash' do
        it 'includes Setting with value of default_value' do
          setting = described_class.all_as_records[key]

          expect(setting).to be_a Setting
          expect(setting).to have_attributes(var: key)
          expect(setting).to have_attributes(value: 'default_value')
        end
      end

      context 'default_value is a Hash' do
        let(:default_value) { { 'foo' => 'fuga' } }

        it 'returns {}' do
          expect(described_class.all_as_records).to eq({})
        end
      end
    end
  end

  describe '.default_settings' do
    subject { described_class.default_settings }

    before do
      allow(RailsSettings::Default).to receive(:enabled?).and_return(enabled)
    end

    context 'RailsSettings::Default.enabled? is false' do
      let(:enabled) { false }

      it 'returns {}' do
        expect(subject).to eq({})
      end
    end

    context 'RailsSettings::Settings.enabled? is true' do
      let(:enabled) { true }

      it 'returns instance of RailsSettings::Default' do
        expect(subject).to be_a RailsSettings::Default
      end
    end
  end
end
