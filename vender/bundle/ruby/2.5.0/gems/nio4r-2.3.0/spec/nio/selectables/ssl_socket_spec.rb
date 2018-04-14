# frozen_string_literal: true

require "spec_helper"
require "openssl"

RSpec.describe OpenSSL::SSL::SSLSocket do
  let(:addr) { "127.0.0.1" }
  let(:port) { next_available_tcp_port }

  let(:ssl_key) { OpenSSL::PKey::RSA.new(1024) }

  let(:ssl_cert) do
    name = OpenSSL::X509::Name.new([%w[CN 127.0.0.1]])
    OpenSSL::X509::Certificate.new.tap do |cert|
      cert.version = 2
      cert.serial = 1
      cert.issuer = name
      cert.subject = name
      cert.not_before = Time.now
      cert.not_after = Time.now + (7 * 24 * 60 * 60)
      cert.public_key = ssl_key.public_key

      cert.sign(ssl_key, OpenSSL::Digest::SHA256.new)
    end
  end

  let(:ssl_server_context) do
    OpenSSL::SSL::SSLContext.new.tap do |ctx|
      ctx.cert = ssl_cert
      ctx.key = ssl_key
    end
  end

  let :readable_subject do
    server = TCPServer.new(addr, port)
    client = TCPSocket.open(addr, port)
    peer = server.accept

    ssl_peer = OpenSSL::SSL::SSLSocket.new(peer, ssl_server_context)
    ssl_peer.sync_close = true

    ssl_client = OpenSSL::SSL::SSLSocket.new(client)
    ssl_client.sync_close = true

    # SSLSocket#connect and #accept are blocking calls.
    thread = Thread.new { ssl_client.connect }

    ssl_peer.accept
    ssl_peer << "data"

    thread.join
    pending "Failed to produce a readable SSL socket" unless select([ssl_client], [], [], 0)

    ssl_client
  end

  let :unreadable_subject do
    server = TCPServer.new(addr, port)
    client = TCPSocket.new(addr, port)
    peer = server.accept

    ssl_peer = OpenSSL::SSL::SSLSocket.new(peer, ssl_server_context)
    ssl_peer.sync_close = true

    ssl_client = OpenSSL::SSL::SSLSocket.new(client)
    ssl_client.sync_close = true

    # SSLSocket#connect and #accept are blocking calls.
    thread = Thread.new { ssl_client.connect }
    ssl_peer.accept
    thread.join

    pending "Failed to produce an unreadable socket" if select([ssl_client], [], [], 0)
    ssl_client
  end

  let :writable_subject do
    server = TCPServer.new(addr, port)
    client = TCPSocket.new(addr, port)
    peer = server.accept

    ssl_peer = OpenSSL::SSL::SSLSocket.new(peer, ssl_server_context)
    ssl_peer.sync_close = true

    ssl_client = OpenSSL::SSL::SSLSocket.new(client)
    ssl_client.sync_close = true

    # SSLSocket#connect and #accept are blocking calls.
    thread = Thread.new { ssl_client.connect }

    ssl_peer.accept
    thread.join

    ssl_client
  end

  let :unwritable_subject do
    server = TCPServer.new(addr, port)
    client = TCPSocket.new(addr, port)
    peer = server.accept

    ssl_peer = OpenSSL::SSL::SSLSocket.new(peer, ssl_server_context)
    ssl_peer.sync_close = true

    ssl_client = OpenSSL::SSL::SSLSocket.new(client)
    ssl_client.sync_close = true

    # SSLSocket#connect and #accept are blocking calls.
    thread = Thread.new { ssl_client.connect }

    ssl_peer.accept
    thread.join

    cntr = 0
    begin
      count = ssl_client.write_nonblock "X" * 1024
      expect(count).not_to eq(0)
      cntr += 1
      t = select [], [ssl_client], [], 0
    rescue IO::WaitReadable, IO::WaitWritable
      pending "SSL will report writable but not accept writes"
    end while t && t[1].include?(ssl_client) && cntr < 30

    # I think the kernel might manage to drain its buffer a bit even after
    # the socket first goes unwritable. Attempt to sleep past this and then
    # attempt to write again
    sleep 0.1

    # Once more for good measure!
    begin
      #        ssl_client.write_nonblock "X" * 1024
      loop { ssl_client.write_nonblock "X" * 1024 }
    rescue OpenSSL::SSL::SSLError
    end

    # Sanity check to make sure we actually produced an unwritable socket
    #      if select([], [ssl_client], [], 0)
    #        pending "Failed to produce an unwritable socket"
    #      end

    ssl_client
  end

  let :pair do
    server = TCPServer.new(addr, port)
    client = TCPSocket.new(addr, port)
    peer = server.accept

    ssl_peer = OpenSSL::SSL::SSLSocket.new(peer, ssl_server_context)
    ssl_peer.sync_close = true

    ssl_client = OpenSSL::SSL::SSLSocket.new(client)
    ssl_client.sync_close = true

    # SSLSocket#connect and #accept are blocking calls.
    thread = Thread.new { ssl_client.connect }
    ssl_peer.accept

    [thread.value, ssl_peer]
  end

  it_behaves_like "an NIO selectable"
  it_behaves_like "an NIO selectable stream"
end
