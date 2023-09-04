# frozen_string_literal: true

require 'rails_helper'

describe ConnectionPool::SharedTimedStack do
  class MiniConnection
    attr_reader :site

    def initialize(site)
      @site = site
    end
  end

  subject { described_class.new(5) { |site| MiniConnection.new(site) } }

  describe '#push' do
    it 'keeps the connection in the stack' do
      subject.push(MiniConnection.new('foo'))
      expect(subject.size).to eq 1
    end
  end

  describe '#pop' do
    it 'returns a connection' do
      expect(subject.pop('foo')).to be_a MiniConnection
    end

    it 'returns the same connection that was pushed in' do
      connection = MiniConnection.new('foo')
      subject.push(connection)
      expect(subject.pop('foo')).to be connection
    end

    it 'does not create more than maximum amount of connections' do
      expect { 6.times { subject.pop('foo', 0) } }.to raise_error Timeout::Error
    end

    it 'repurposes a connection for a different site when maximum amount is reached' do
      5.times { subject.push(MiniConnection.new('foo')) }
      expect(subject.pop('bar')).to be_a MiniConnection
    end
  end

  describe '#empty?' do
    it 'returns true when no connections on the stack' do
      expect(subject.empty?).to be true
    end

    it 'returns false when there are connections on the stack' do
      subject.push(MiniConnection.new('foo'))
      expect(subject.empty?).to be false
    end
  end

  describe '#size' do
    it 'returns the number of connections on the stack' do
      2.times { subject.push(MiniConnection.new('foo')) }
      expect(subject.size).to eq 2
    end
  end
end
