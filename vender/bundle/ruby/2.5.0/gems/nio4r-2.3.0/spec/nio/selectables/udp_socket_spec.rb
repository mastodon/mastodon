# frozen_string_literal: true

require "spec_helper"

RSpec.describe UDPSocket, if: !defined?(JRUBY_VERSION) do
  let(:udp_port) { 23_456 }

  let :readable_subject do
    sock = UDPSocket.new
    sock.bind("127.0.0.1", udp_port)

    peer = UDPSocket.new
    peer.send("hi there", 0, "127.0.0.1", udp_port)

    sock
  end

  let :unreadable_subject do
    sock = UDPSocket.new
    sock.bind("127.0.0.1", udp_port + 1)
    sock
  end

  let :writable_subject do
    peer = UDPSocket.new
    peer.connect "127.0.0.1", udp_port
    cntr = 0
    begin
      peer.send("X" * 1024, 0)
      cntr += 1
      t = select [], [peer], [], 0
    rescue Errno::ECONNREFUSED => ex
      skip "Couln't make writable UDPSocket subject: #{ex.class}: #{ex}"
    end while t && t[1].include?(peer) && cntr < 5
    peer
  end

  let :unwritable_subject do
    pending "come up with a UDPSocket that's blocked on writing"
  end

  it_behaves_like "an NIO selectable"
end
