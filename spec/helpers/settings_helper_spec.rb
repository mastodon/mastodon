# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SettingsHelper do
  describe '#user_settings_collection' do
    subject { helper.user_settings_collection(value) }

    context 'with valid value' do
      let(:value) { 'web.contrast' }

      it { is_expected.to eq(%w(auto high)) }
    end

    context 'with invalid value' do
      let(:value) { 'web.nothing_at_this_key_at_all_fake_fake_fake' }

      it { is_expected.to be_empty }
    end
  end

  describe 'session_device_icon' do
    context 'with a mobile device' do
      let(:session) { SessionActivation.new(user_agent: 'Mozilla/5.0 (iPhone)') }

      it 'detects the device and returns a descriptive string' do
        result = helper.session_device_icon(session)

        expect(result).to eq('smartphone')
      end
    end

    context 'with a tablet device' do
      let(:session) { SessionActivation.new(user_agent: 'Mozilla/5.0 (iPad)') }

      it 'detects the device and returns a descriptive string' do
        result = helper.session_device_icon(session)

        expect(result).to eq('tablet')
      end
    end

    context 'with a desktop device' do
      let(:session) { SessionActivation.new(user_agent: 'Mozilla/5.0 (Macintosh)') }

      it 'detects the device and returns a descriptive string' do
        result = helper.session_device_icon(session)

        expect(result).to eq('desktop_mac')
      end
    end
  end
end
