require 'global_id'
require 'active_support/message_verifier'
require 'time'

class SignedGlobalID < GlobalID
  class ExpiredMessage < StandardError; end

  class << self
    attr_accessor :verifier

    def parse(sgid, options = {})
      super verify(sgid.to_s, options), options
    end

    # Grab the verifier from options and fall back to SignedGlobalID.verifier.
    # Raise ArgumentError if neither is available.
    def pick_verifier(options)
      options.fetch :verifier do
        verifier || raise(ArgumentError, 'Pass a `verifier:` option with an `ActiveSupport::MessageVerifier` instance, or set a default SignedGlobalID.verifier.')
      end
    end

    attr_accessor :expires_in

    DEFAULT_PURPOSE = "default"

    def pick_purpose(options)
      options.fetch :for, DEFAULT_PURPOSE
    end

    private
      def verify(sgid, options)
        metadata = pick_verifier(options).verify(sgid)

        raise_if_expired(metadata['expires_at'])

        metadata['gid'] if pick_purpose(options) == metadata['purpose']
      rescue ActiveSupport::MessageVerifier::InvalidSignature, ExpiredMessage
        nil
      end

      def raise_if_expired(expires_at)
        if expires_at && Time.now.utc > Time.iso8601(expires_at)
          raise ExpiredMessage, 'This signed global id has expired.'
        end
      end
  end

  attr_reader :verifier, :purpose, :expires_at

  def initialize(gid, options = {})
    super
    @verifier = self.class.pick_verifier(options)
    @purpose = self.class.pick_purpose(options)
    @expires_at = pick_expiration(options)
  end

  def to_s
    @sgid ||= @verifier.generate(to_h)
  end
  alias to_param to_s

  def to_h
    # Some serializers decodes symbol keys to symbols, others to strings.
    # Using string keys remedies that.
    { 'gid' => @uri.to_s, 'purpose' => purpose, 'expires_at' => encoded_expiration }
  end

  def ==(other)
    super && @purpose == other.purpose
  end

  private
    def encoded_expiration
      expires_at.utc.iso8601(3) if expires_at
    end

    def pick_expiration(options)
      return options[:expires_at] if options.key?(:expires_at)

      if expires_in = options.fetch(:expires_in) { self.class.expires_in }
        expires_in.from_now
      end
    end
end
