# frozen_string_literal: true

require 'rails_helper'

describe ConnectionPool::SharedTimedStack do
  let(:shared_size) { Concurrent::AtomicFixnum.new }

  subject { described_class.new(shared_size, 5) { Object.new } }

  describe '#push' do
    it 'keeps the connection in the stack' do
      subject.push(Object.new)
      expect(subject.size).to eq 1
    end
  end

  describe '#pop' do
    it 'returns a connection' do
      expect(subject.pop).to be_an Object
    end

    it 'returns the same connection that was pushed in' do
      connection = Object.new
      subject.push(connection)
      expect(subject.pop).to be connection
    end

    it 'does not create more than maximum amount of connections' do
      expect { 6.times { subject.pop(0) } }.to raise_error Timeout::Error
    end
  end

  describe '#empty?' do
    it 'returns true when no connections on the stack' do
      expect(subject.empty?).to be true
    end

    it 'returns false when there are connections on the stack' do
      subject.push(Object.new)
      expect(subject.empty?).to be false
    end
  end

  describe '#delete' do
    it 'removes a specific connection from the stack' do
      connection = Object.new
      subject.push(connection)
      subject.push(Object.new)
      expect(subject.size).to eq 2
      subject.delete(connection)
      expect(subject.size).to eq 1
      expect(subject.pop).to_not be connection
    end
  end

  describe '#size' do
    it 'returns the number of connections on the stack' do
      2.times { subject.push(Object.new) }
      expect(subject.size).to eq 2
    end
  end

  describe '#each_connection' do
    it 'iterates over each connection on the stack' do
      2.times { subject.push(Object.new) }

      touched = 0

      subject.each_connection do |connection|
        touched += 1 if connection
      end

      expect(touched).to eq 2
    end
  end
end
