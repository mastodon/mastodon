# frozen_string_literal: true

require "forwardable"

module HTTP
  class Headers
    # Provides shared behavior for {HTTP::Request} and {HTTP::Response}.
    # Expects `@headers` to be an instance of {HTTP::Headers}.
    #
    # @example Usage
    #
    #   class MyHttpRequest
    #     include HTTP::Headers::Mixin
    #
    #     def initialize
    #       @headers = HTTP::Headers.new
    #     end
    #   end
    module Mixin
      extend Forwardable

      # @return [HTTP::Headers]
      attr_reader :headers

      # @!method []
      #   (see HTTP::Headers#[])
      def_delegator :headers, :[]

      # @!method []=
      #   (see HTTP::Headers#[]=)
      def_delegator :headers, :[]=
    end
  end
end
