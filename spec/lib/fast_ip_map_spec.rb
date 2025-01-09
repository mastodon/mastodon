# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FastIpMap do
  describe '#include?' do
    subject { described_class.new([IPAddr.new('20.4.0.0/16'), IPAddr.new('145.22.30.0/24'), IPAddr.new('189.45.86.3')]) }

    it 'returns true for an exact match' do
      expect(subject.include?(IPAddr.new('189.45.86.3'))).to be true
    end

    it 'returns true for a range match' do
      expect(subject.include?(IPAddr.new('20.4.45.7'))).to be true
    end

    it 'returns false for no match' do
      expect(subject.include?(IPAddr.new('145.22.40.64'))).to be false
    end
  end
end
