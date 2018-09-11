# frozen_string_literal: true

require 'ipaddr'
require 'socket'

class Request
  REQUEST_TARGET = '(request-target)'

  include RoutingHelper

  def initialize(verb, url, **options)
    raise ArgumentError if url.blank?

    @verb    = verb
    @url     = Addressable::URI.parse(url).normalize
    @options = options.merge(use_proxy? ? Rails.configuration.x.http_client_proxy : { socket_class: Socket })
    @headers = {}

    raise Mastodon::HostValidationError, 'Instance does not support hidden service connections' if block_hidden_service?

    set_common_headers!
    set_digest! if options.key?(:body)
  end

  def on_behalf_of(account, key_id_format = :acct, sign_with: nil)
    raise ArgumentError unless account.local?

    @account       = account
    @keypair       = sign_with.present? ? OpenSSL::PKey::RSA.new(sign_with) : @account.keypair
    @key_id_format = key_id_format

    self
  end

  def add_headers(new_headers)
    @headers.merge!(new_headers)
    self
  end

  def perform
    begin
      response = http_client.headers(headers).public_send(@verb, @url.to_s, @options)
    rescue => e
      raise e.class, "#{e.message} on #{@url}", e.backtrace[0]
    end

    begin
      yield response.extend(ClientLimit)
    ensure
      http_client.close
    end
  end

  def headers
    (@account ? @headers.merge('Signature' => signature) : @headers).without(REQUEST_TARGET)
  end

  private

  def set_common_headers!
    @headers[REQUEST_TARGET]    = "#{@verb} #{@url.path}"
    @headers['User-Agent']      = Mastodon::Version.user_agent
    @headers['Host']            = @url.host
    @headers['Date']            = Time.now.utc.httpdate
    @headers['Accept-Encoding'] = 'gzip' if @verb != :head
  end

  def set_digest!
    @headers['Digest'] = "SHA-256=#{Digest::SHA256.base64digest(@options[:body])}"
  end

  def signature
    algorithm = 'rsa-sha256'
    signature = Base64.strict_encode64(@keypair.sign(OpenSSL::Digest::SHA256.new, signed_string))

    "keyId=\"#{key_id}\",algorithm=\"#{algorithm}\",headers=\"#{signed_headers.keys.join(' ').downcase}\",signature=\"#{signature}\""
  end

  def signed_string
    signed_headers.map { |key, value| "#{key.downcase}: #{value}" }.join("\n")
  end

  def signed_headers
    @headers.without('User-Agent', 'Accept-Encoding')
  end

  def key_id
    case @key_id_format
    when :acct
      @account.to_webfinger_s
    when :uri
      [ActivityPub::TagManager.instance.uri_for(@account), '#main-key'].join
    end
  end

  def timeout
    { write: 10, connect: 10, read: 10 }
  end

  def http_client
    @http_client ||= HTTP.use(:auto_inflate).timeout(:per_operation, timeout).follow(max_hops: 2)
  end

  def use_proxy?
    Rails.configuration.x.http_client_proxy.present?
  end

  def block_hidden_service?
    !Rails.configuration.x.access_to_hidden_service && /\.(onion|i2p)$/.match(@url.host)
  end

  module ClientLimit
    def body_with_limit(limit = 1.megabyte)
      raise Mastodon::LengthValidationError if content_length.present? && content_length > limit

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

        raise Mastodon::LengthValidationError if contents.bytesize > limit
      end

      contents
    end
  end

  class Socket < TCPSocket
    class << self
      def open(host, *args)
        return super host, *args if thru_hidden_service? host
        outer_e = nil
        Addrinfo.foreach(host, nil, nil, :SOCK_STREAM) do |address|
          begin
            raise Mastodon::HostValidationError if PrivateAddressCheck.private_address? IPAddr.new(address.ip_address)
            return super address.ip_address, *args
          rescue => e
            outer_e = e
          end
        end
        raise outer_e if outer_e
      end

      alias new open

      def thru_hidden_service?(host)
        Rails.configuration.x.access_to_hidden_service && /\.(onion|i2p)$/.match(host)
      end
    end
  end

  private_constant :ClientLimit, :Socket
end
