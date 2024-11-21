# frozen_string_literal: true

require 'ipaddr'
require 'socket'
require 'resolv'

# Use our own timeout class to avoid using HTTP.rb's timeout block
# around the Socket#open method, since we use our own timeout blocks inside
# that method
#
# Also changes how the read timeout behaves so that it is cumulative (closer
# to HTTP::Timeout::Global, but still having distinct timeouts for other
# operation types)
class PerOperationWithDeadline < HTTP::Timeout::PerOperation
  READ_DEADLINE = 30

  def initialize(*args)
    super

    @read_deadline = options.fetch(:read_deadline, READ_DEADLINE)
  end

  def connect(socket_class, host, port, nodelay = false)
    @socket = socket_class.open(host, port)
    @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1) if nodelay
  end

  # Reset deadline when the connection is re-used for different requests
  def reset_counter
    @deadline = nil
  end

  # Read data from the socket
  def readpartial(size, buffer = nil)
    @deadline ||= Process.clock_gettime(Process::CLOCK_MONOTONIC) + @read_deadline

    timeout = false
    loop do
      result = @socket.read_nonblock(size, buffer, exception: false)

      return :eof if result.nil?

      remaining_time = @deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
      raise HTTP::TimeoutError, "Read timed out after #{@read_timeout} seconds" if timeout
      raise HTTP::TimeoutError, "Read timed out after a total of #{@read_deadline} seconds" if remaining_time <= 0
      return result if result != :wait_readable

      # marking the socket for timeout. Why is this not being raised immediately?
      # it seems there is some race-condition on the network level between calling
      # #read_nonblock and #wait_readable, in which #read_nonblock signalizes waiting
      # for reads, and when waiting for x seconds, it returns nil suddenly without completing
      # the x seconds. In a normal case this would be a timeout on wait/read, but it can
      # also mean that the socket has been closed by the server. Therefore we "mark" the
      # socket for timeout and try to read more bytes. If it returns :eof, it's all good, no
      # timeout. Else, the first timeout was a proper timeout.
      # This hack has to be done because io/wait#wait_readable doesn't provide a value for when
      # the socket is closed by the server, and HTTP::Parser doesn't provide the limit for the chunks.
      timeout = true unless @socket.to_io.wait_readable([remaining_time, @read_timeout].min)
    end
  end
end

class Request
  REQUEST_TARGET = '(request-target)'

  # We enforce a 5s timeout on DNS resolving, 5s timeout on socket opening
  # and 5s timeout on the TLS handshake, meaning the worst case should take
  # about 15s in total
  TIMEOUT = { connect_timeout: 5, read_timeout: 10, write_timeout: 10, read_deadline: 30 }.freeze

  include RoutingHelper

  def initialize(verb, url, **options)
    raise ArgumentError if url.blank?

    @verb        = verb
    @url         = Addressable::URI.parse(url).normalize
    @http_client = options.delete(:http_client)
    @allow_local = options.delete(:allow_local)
    @full_path   = !options.delete(:omit_query_string)
    @options     = options.merge(socket_class: use_proxy? || @allow_local ? ProxySocket : Socket)
    @options     = @options.merge(timeout_class: PerOperationWithDeadline, timeout_options: TIMEOUT)
    @options     = @options.merge(proxy_url) if use_proxy?
    @headers     = {}

    raise Mastodon::HostValidationError, 'Instance does not support hidden service connections' if block_hidden_service?

    set_common_headers!
    set_digest! if options.key?(:body)
  end

  def on_behalf_of(actor, sign_with: nil)
    raise ArgumentError, 'actor must not be nil' if actor.nil?

    @actor         = actor
    @keypair       = sign_with.present? ? OpenSSL::PKey::RSA.new(sign_with) : @actor.keypair

    self
  end

  def add_headers(new_headers)
    @headers.merge!(new_headers)
    self
  end

  def perform
    begin
      response = http_client.request(@verb, @url.to_s, @options.merge(headers: headers))
    rescue => e
      raise e.class, "#{e.message} on #{@url}", e.backtrace[0]
    end

    begin
      # If we are using a persistent connection, we have to
      # read every response to be able to move forward at all.
      # However, simply calling #to_s or #flush may not be safe,
      # as the response body, if malicious, could be too big
      # for our memory. So we use the #body_with_limit method
      response.body_with_limit if http_client.persistent?

      yield response if block_given?
    ensure
      http_client.close unless http_client.persistent?
    end
  end

  def headers
    (@actor ? @headers.merge('Signature' => signature) : @headers).without(REQUEST_TARGET)
  end

  class << self
    def valid_url?(url)
      begin
        parsed_url = Addressable::URI.parse(url)
      rescue Addressable::URI::InvalidURIError
        return false
      end

      %w(http https).include?(parsed_url.scheme) && parsed_url.host.present?
    end

    def http_client
      HTTP.use(:auto_inflate).follow(max_hops: 3)
    end
  end

  private

  def set_common_headers!
    @headers[REQUEST_TARGET]    = request_target
    @headers['User-Agent']      = Mastodon::Version.user_agent
    @headers['Host']            = @url.host
    @headers['Date']            = Time.now.utc.httpdate
    @headers['Accept-Encoding'] = 'gzip' if @verb != :head
  end

  def set_digest!
    @headers['Digest'] = "SHA-256=#{Digest::SHA256.base64digest(@options[:body])}"
  end

  def request_target
    if @url.query.nil? || !@full_path
      "#{@verb} #{@url.path}"
    else
      "#{@verb} #{@url.path}?#{@url.query}"
    end
  end

  def signature
    algorithm = 'rsa-sha256'
    signature = Base64.strict_encode64(@keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))

    "keyId=\"#{key_id}\",algorithm=\"#{algorithm}\",headers=\"#{signed_headers.keys.join(' ').downcase}\",signature=\"#{signature}\""
  end

  def signed_string
    signed_headers.map { |key, value| "#{key.downcase}: #{value}" }.join("\n")
  end

  def signed_headers
    @headers.without('User-Agent', 'Accept-Encoding')
  end

  def key_id
    ActivityPub::TagManager.instance.key_uri_for(@actor)
  end

  def http_client
    @http_client ||= Request.http_client
  end

  def use_proxy?
    proxy_url.present?
  end

  def proxy_url
    if hidden_service? && Rails.configuration.x.http_client_hidden_proxy.present?
      Rails.configuration.x.http_client_hidden_proxy
    else
      Rails.configuration.x.http_client_proxy
    end
  end

  def block_hidden_service?
    !Rails.configuration.x.access_to_hidden_service && hidden_service?
  end

  def hidden_service?
    /\.(onion|i2p)$/.match?(@url.host)
  end

  module ClientLimit
    def truncated_body(limit = 1.megabyte)
      if charset.nil?
        encoding = Encoding::BINARY
      else
        begin
          encoding = Encoding.find(charset)
        rescue ArgumentError
          encoding = Encoding::BINARY
        end
      end

      contents = String.new(encoding: encoding)

      while (chunk = readpartial)
        contents << chunk
        chunk.clear

        break if contents.bytesize > limit
      end

      contents
    end

    def body_with_limit(limit = 1.megabyte)
      require_limit_not_exceeded!(limit)

      contents = truncated_body(limit)
      raise Mastodon::LengthValidationError, "Body size exceeds limit of #{limit}" if contents.bytesize > limit

      contents
    end

    def require_limit_not_exceeded!(limit)
      raise Mastodon::LengthValidationError, "Content-Length #{content_length} exceeds limit of #{limit}" if content_length.present? && content_length > limit
    end
  end

  if ::HTTP::Response.methods.include?(:body_with_limit) && !Rails.env.production?
    abort 'HTTP::Response#body_with_limit is already defined, the monkey patch will not be applied'
  else
    class ::HTTP::Response
      include Request::ClientLimit
    end
  end

  class Socket < TCPSocket
    class << self
      def open(host, *args)
        outer_e = nil
        port    = args.first

        addresses = []
        begin
          addresses = [IPAddr.new(host)]
        rescue IPAddr::InvalidAddressError
          Resolv::DNS.open do |dns|
            dns.timeouts = 5
            addresses = dns.getaddresses(host)
            addresses = addresses.filter { |addr| addr.is_a?(Resolv::IPv6) }.take(2) + addresses.filter { |addr| !addr.is_a?(Resolv::IPv6) }.take(2)
          end
        end

        socks = []
        addr_by_socket = {}

        addresses.each do |address|
          check_private_address(address, host)

          sock     = ::Socket.new(address.is_a?(Resolv::IPv6) ? ::Socket::AF_INET6 : ::Socket::AF_INET, ::Socket::SOCK_STREAM, 0)
          sockaddr = ::Socket.pack_sockaddr_in(port, address.to_s)

          sock.setsockopt(::Socket::IPPROTO_TCP, ::Socket::TCP_NODELAY, 1)

          sock.connect_nonblock(sockaddr)

          # If that hasn't raised an exception, we somehow managed to connect
          # immediately, close pending sockets and return immediately
          socks.each(&:close)
          return sock
        rescue IO::WaitWritable
          socks << sock
          addr_by_socket[sock] = sockaddr
        rescue => e
          outer_e = e
        end

        until socks.empty?
          _, available_socks, = IO.select(nil, socks, nil, Request::TIMEOUT[:connect_timeout])

          if available_socks.nil?
            socks.each(&:close)
            raise HTTP::TimeoutError, "Connect timed out after #{Request::TIMEOUT[:connect_timeout]} seconds"
          end

          available_socks.each do |sock|
            socks.delete(sock)

            begin
              sock.connect_nonblock(addr_by_socket[sock])
            rescue Errno::EISCONN
              # Do nothing
            rescue => e
              sock.close
              outer_e = e
              next
            end

            socks.each(&:close)
            return sock
          end
        end

        if outer_e
          raise outer_e
        else
          raise SocketError, "No address for #{host}"
        end
      end

      alias new open

      def check_private_address(address, host)
        addr = IPAddr.new(address.to_s)

        return if Rails.env.development? || Rails.configuration.x.private_address_exceptions.any? { |range| range.include?(addr) }

        raise Mastodon::PrivateNetworkAddressError, host if PrivateAddressCheck.private_address?(addr)
      end
    end
  end

  class ProxySocket < Socket
    class << self
      def check_private_address(_address, _host)
        # Accept connections to private addresses as HTTP proxies will usually
        # be on local addresses
        nil
      end
    end
  end

  private_constant :ClientLimit, :Socket, :ProxySocket
end
