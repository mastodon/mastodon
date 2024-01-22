# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSettings do
  subject { described_class.new(json) }

  let(:json) { {} }

  describe '#[]' do
    context 'when setting is not set' do
      it 'returns default value' do
        expect(subject[:always_send_emails]).to be false
      end
    end

    context 'when setting is set' do
      let(:json) { { default_language: 'fr' } }

      it 'returns value' do
        expect(subject[:default_language]).to eq 'fr'
      end
    end

    context 'when setting was not defined' do
      it 'raises error' do
        expect { subject[:foo] }.to raise_error UserSettings::KeyError
      end
    end
  end

  describe '#[]=' do
    context 'when value matches type' do
      before do
        subject[:always_send_emails] = true
      end

      it 'updates value' do
        expect(subject[:always_send_emails]).to be true
      end
    end

    context 'when value needs to be type-cast' do
      before do
        subject[:always_send_emails] = '1'
      end

      it 'updates value with a type-cast' do
        expect(subject[:always_send_emails]).to be true
      end
    end

    context 'when the setting has a closed set of values' do
      it 'updates the attribute when given a valid value' do
        expect { subject[:'web.display_media'] = :show_all }.to change { subject[:'web.display_media'] }.from('default').to('show_all')
      end

      it 'raises an error when given an invalid value' do
        expect { subject[:'web.display_media'] = 'invalid value' }.to raise_error ArgumentError
      end
    end
  end

  describe '#update' do
    before do
      subject.update(always_send_emails: true, default_language: 'fr', default_privacy: nil)
    end

    it 'updates values' do
      expect(subject[:always_send_emails]).to be true
      expect(subject[:default_language]).to eq 'fr'
    end

    it 'does not set values that are nil' do
      expect(subject.as_json).to_not include(default_privacy: nil)
    end
  end

  describe '#as_json' do
    let(:json) { { default_language: 'fr' } }

    it 'returns hash' do
      expect(subject.as_json).to eq json
    end
  end

  describe '.keys' do
    it 'returns an array' do
      expect(described_class.keys).to be_a Array
    end
  end

  describe '.definition_for' do
    context 'when key is defined' do
      it 'returns a setting' do
        expect(described_class.definition_for(:always_send_emails)).to be_a UserSettings::Setting
      end
    end

    context 'when key is not defined' do
      it 'returns nil' do
        expect(described_class.definition_for(:foo)).to be_nil
      end
    end
  end

  describe '.definition_for?' do
    context 'when key is defined' do
      it 'returns true' do
        expect(described_class.definition_for?(:always_send_emails)).to be true
      end
    end

    context 'when key is not defined' do
      it 'returns false' do
        expect(described_class.definition_for?(:foo)).to be false
      end
    end
  end
end
