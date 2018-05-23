# frozen_string_literal: true

require "spec_helper"
require "socket"

RSpec.describe NIO::Monitor do
  let(:addr) { "127.0.0.1" }
  let(:port) { next_available_tcp_port }

  let(:reader) { TCPServer.new(addr, port) }
  let(:writer) { TCPSocket.new(addr, port) }

  let(:selector) { NIO::Selector.new }

  subject(:monitor) { selector.register(writer, :rw) }
  subject(:peer)    { selector.register(reader, :r) }

  before { reader }
  before { writer }
  after  { reader.close }
  after  { writer.close }
  after  { selector.close }

  describe "#interests" do
    it "knows its interests" do
      expect(peer.interests).to eq(:r)
      expect(monitor.interests).to eq(:rw)
    end
  end

  describe "#interests=" do
    it "can set interests to nil" do
      expect(monitor.interests).not_to eq(nil)
      monitor.interests = nil
      expect(monitor.interests).to eq(nil)
    end

    it "changes the interest set" do
      expect(monitor.interests).not_to eq(:w)
      monitor.interests = :w
      expect(monitor.interests).to eq(:w)
    end

    it "raises EOFError if interests are changed after the monitor is closed" do
      monitor.close
      expect { monitor.interests = :rw }.to raise_error(EOFError)
    end
  end

  describe "#add_interest" do
    it "sets a new interest if it isn't currently registered" do
      monitor.interests = :r
      expect(monitor.interests).to eq(:r)

      expect(monitor.add_interest(:w)).to eq(:rw)
      expect(monitor.interests).to eq(:rw)
    end

    it "acts idempotently" do
      monitor.interests = :r
      expect(monitor.interests).to eq(:r)

      expect(monitor.add_interest(:r)).to eq(:r)
      expect(monitor.interests).to eq(:r)
    end

    it "raises ArgumentError if given a bogus option" do
      expect { monitor.add_interest(:derp) }.to raise_error(ArgumentError)
    end
  end

  describe "#remove_interest" do
    it "removes an interest from the set" do
      expect(monitor.interests).to eq(:rw)

      expect(monitor.remove_interest(:r)).to eq(:w)
      expect(monitor.interests).to eq(:w)
    end

    it "can clear the last interest" do
      monitor.interests = :w
      expect(monitor.interests).to eq(:w)

      expect(monitor.remove_interest(:w)).to be_nil
      expect(monitor.interests).to be_nil
    end

    it "acts idempotently" do
      monitor.interests = :w
      expect(monitor.interests).to eq(:w)

      expect(monitor.remove_interest(:r)).to eq(:w)
      expect(monitor.interests).to eq(:w)
    end

    it "raises ArgumentError if given a bogus option" do
      expect { monitor.add_interest(:derp) }.to raise_error(ArgumentError)
    end
  end

  describe "#io" do
    it "knows its IO object" do
      expect(monitor.io).to eq(writer)
    end
  end

  describe "#selector" do
    it "knows its selector" do
      expect(monitor.selector).to eq(selector)
    end
  end

  describe "#value=" do
    it "stores arbitrary values" do
      monitor.value = 42
      expect(monitor.value).to eq(42)
    end
  end

  describe "#readiness" do
    it "knows what operations IO objects are ready for" do
      # For whatever odd reason this breaks unless we eagerly evaluate monitor
      reader_peer = peer
      writer_peer = monitor

      selected = selector.select(0)
      expect(selected).to include(writer_peer)

      expect(writer_peer.readiness).to eq(:w)
      expect(writer_peer).not_to be_readable
      expect(writer_peer).to be_writable

      writer << "testing 1 2 3"

      selected = selector.select(0)
      expect(selected).to include(reader_peer)

      expect(reader_peer.readiness).to eq(:r)
      expect(reader_peer).to be_readable
      expect(reader_peer).not_to be_writable
    end
  end

  describe "#close" do
    it "closes" do
      expect(monitor).not_to be_closed
      expect(selector.registered?(writer)).to be_truthy

      monitor.close
      expect(monitor).to be_closed
      expect(selector.registered?(writer)).to be_falsey
    end

    it "closes even if the selector has been shutdown" do
      expect(monitor).not_to be_closed
      selector.close # forces shutdown
      expect(monitor).not_to be_closed
      monitor.close
      expect(monitor).to be_closed
    end
  end
end
