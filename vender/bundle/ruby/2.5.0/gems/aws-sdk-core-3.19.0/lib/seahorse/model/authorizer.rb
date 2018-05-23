module Seahorse
  module Model
    class Authorizer

      def initialize
        @type = 'provided'
        @placement = {}
      end

      # @return [String]
      attr_accessor :name

      # @return [String]
      attr_accessor :type

      # @return [Hash]
      attr_accessor :placement

    end
  end
end
