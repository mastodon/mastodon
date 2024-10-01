# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IpBlock do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:ip) }
    it { is_expected.to validate_presence_of(:severity) }

    it 'validates ip uniqueness', :aggregate_failures do
      described_class.create!(ip: '127.0.0.1', severity: :no_access)

      ip_block = described_class.new(ip: '127.0.0.1', severity: :no_access)

      expect(ip_block).to_not be_valid
      expect(ip_block).to model_have_error_on_field(:ip)
    end
  end

  describe '#to_log_human_identifier' do
    let(:ip_block) { described_class.new(ip: '192.168.0.1') }

    it 'combines the IP and prefix into a string' do
      result = ip_block.to_log_human_identifier

      expect(result).to eq('192.168.0.1/32')
    end
  end

  describe '.blocked?' do
    context 'when the IP is blocked' do
      it 'returns true' do
        described_class.create!(ip: '127.0.0.1', severity: :no_access)

        expect(described_class.blocked?('127.0.0.1')).to be true
      end
    end

    context 'when the IP is not blocked' do
      it 'returns false' do
        expect(described_class.blocked?('127.0.0.1')).to be false
      end
    end
  end

  describe 'after_commit' do
    it 'resets the cache' do
      allow(Rails.cache).to receive(:delete)

      described_class.create!(ip: '127.0.0.1', severity: :no_access)

      expect(Rails.cache).to have_received(:delete).with(described_class::CACHE_KEY)
    end
  end
end
