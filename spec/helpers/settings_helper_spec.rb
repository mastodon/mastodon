# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SettingsHelper do
  describe '#application_scope_groups' do
    subject { helper.application_scope_groups }

    before { allow(Doorkeeper.configuration).to receive(:scopes).and_return(scopes) }

    context 'with configured scopes' do
      let(:scopes) { %w(read read:accounts profile write write:accounts) }

      it { is_expected.to eq [%w(read read:accounts), %w(profile), %w(write write:accounts)] }
    end

    context 'with empty scopes' do
      let(:scopes) { [] }

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
