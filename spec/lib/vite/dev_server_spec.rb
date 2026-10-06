# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vite::DevServer do
  subject { described_class.new(config:) }

  # port == 0 means that it will pick up any available port provided by the OS
  let(:server) { TCPServer.new('localhost', 0) }
  let!(:config) { Struct.new(:host, :port).new('localhost', server.addr[1]) }

  after { server.close }

  describe '#running?' do
    context 'when the server is running' do
      it 'returns true' do
        expect(subject.running?).to be(true)
      end
    end

    context 'when the server is not running' do
      it 'returns false' do
        server.close

        expect(subject.running?).to be(false)
      end
    end
  end
end
