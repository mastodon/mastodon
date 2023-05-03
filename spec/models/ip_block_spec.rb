# frozen_string_literal: true

require 'rails_helper'

describe IpBlock do
  describe 'to_log_human_identifier' do
    let(:ip_block) { described_class.new(ip: '192.168.0.1') }

    it 'combines the IP and prefix into a string' do
      result = ip_block.to_log_human_identifier

      expect(result).to eq('192.168.0.1/32')
    end
  end
end
