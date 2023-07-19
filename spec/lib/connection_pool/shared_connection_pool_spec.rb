# frozen_string_literal: true

require 'rails_helper'

describe ConnectionPool::SharedConnectionPool do
  subject { described_class.new(size: 5, timeout: 5) { |site| mini_connection_class.new(site) } }

  let(:mini_connection_class) do
    Class.new do
      attr_reader :site

      def initialize(site)
        @site = site
      end
    end
  end

  describe '#with' do
    it 'runs a block with a connection' do
      block_run = false

      subject.with('foo') do |connection|
        expect(connection).to be_a mini_connection_class
        block_run = true
      end

      expect(block_run).to be true
    end
  end
end
