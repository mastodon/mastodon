module Aws
  module Sigv4
    class Signature

      # @api private
      def initialize(options)
        options.each_pair do |attr_name, attr_value|
          send("#{attr_name}=", attr_value)
        end
      end

      # @return [Hash<String,String>] A hash of headers that should
      #   be applied to the HTTP request. Header keys are lower
      #   cased strings and may include the following:
      #
      #   * 'host'
      #   * 'x-amz-date'
      #   * 'x-amz-security-token'
      #   * 'x-amz-content-sha256'
      #   * 'authorization'
      #
      attr_accessor :headers

      # @return [String] For debugging purposes.
      attr_accessor :canonical_request

      # @return [String] For debugging purposes.
      attr_accessor :string_to_sign

      # @return [String] For debugging purposes.
      attr_accessor :content_sha256

    end
  end
end
