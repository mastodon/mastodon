# frozen_string_literal: true

require 'rails_helper'

describe ConnectionPool::SharedConnectionPool do
  class MiniConnection
    attr_reader :site

    def initialize(site)
      @site = site
    end
  end

  subject { described_class.new(size: 5, timeout: 5) { |site| MiniConnection.new(site) } }

  describe '#with' do
    it 'runs a block with a connection' do
      block_run = false

      subject.with('foo') do |connection|
        expect(connection).to be_a MiniConnection
        block_run = true
      end

      expect(block_run).to be true
    end
  end
end
