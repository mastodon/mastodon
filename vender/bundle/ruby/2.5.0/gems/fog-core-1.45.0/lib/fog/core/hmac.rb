module Fog
  class HMAC
    def initialize(type, key)
      @key = key
      case type
      when "sha1"
        setup_sha1
      when "sha256"
        setup_sha256
      end
    end

    def sign(data)
      @signer.call(data)
    end

    private

    def setup_sha1
      @digest = OpenSSL::Digest.new("sha1")
      @signer = lambda do |data|
        OpenSSL::HMAC.digest(@digest, @key, data)
      end
    end

    def setup_sha256
      @digest = OpenSSL::Digest.new("sha256")
      @signer = lambda do |data|
        OpenSSL::HMAC.digest(@digest, @key, data)
      end
    end
  end
end
