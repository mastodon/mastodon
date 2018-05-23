# frozen_string_literal: true

require "spec_helper"

RSpec.describe TCPSocket do
  let(:addr) { "127.0.0.1" }
  let(:port) { next_available_tcp_port }

  let :readable_subject do
    server = TCPServer.new(addr, port)
    sock = TCPSocket.new(addr, port)
    peer = server.accept
    peer << "data"
    sock
  end

  let :unreadable_subject do
    TCPServer.new(addr, port)
    sock = TCPSocket.new(addr, port)

    # Sanity check to make sure we actually produced an unreadable socket
    pending "Failed to produce an unreadable socket" if select([sock], [], [], 0)

    sock
  end

  let :writable_subject do
    TCPServer.new(addr, port)
    TCPSocket.new(addr, port)
  end

  let :unwritable_subject do
    server = TCPServer.new(addr, port)
    sock = TCPSocket.new(addr, port)

    # TODO: close this socket
    _peer = server.accept

    loop do
      sock.write_nonblock "X" * 1024
      _, writers = Kernel.select([], [sock], [], 0)

      break unless writers && writers.include?(sock)
    end

    # HAX: I think the kernel might manage to drain its buffer a bit even after
    # the socket first goes unwritable. Attempt to sleep past this and then
    # attempt to write again
    sleep 0.1

    # Once more for good measure!
    begin
      sock.write_nonblock "X" * 1024
    rescue Errno::EWOULDBLOCK
    end

    # Sanity check to make sure we actually produced an unwritable socket
    pending "Failed to produce an unwritable socket" if select([], [sock], [], 0)

    sock
  end

  let :pair do
    server = TCPServer.new(addr, port)
    client = TCPSocket.new(addr, port)
    [client, server.accept]
  end

  it_behaves_like "an NIO selectable"
  it_behaves_like "an NIO selectable stream"
  it_behaves_like "an NIO bidirectional stream"

  context :connect do
    it "selects writable when connected", retry: 5 do # retry: Flaky on OS X
      begin
        server = TCPServer.new(addr, port)
        selector = NIO::Selector.new

        client = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
        monitor = selector.register(client, :w)

        expect do
          client.connect_nonblock Socket.sockaddr_in(port, addr)
        end.to raise_exception Errno::EINPROGRESS

        expect(selector.select(0.001)).to include monitor
        result = client.getsockopt(::Socket::SOL_SOCKET, ::Socket::SO_ERROR)
        expect(result.unpack("i").first).to be_zero
      ensure
        server.close rescue nil
        selector.close rescue nil
      end
    end
  end
end
