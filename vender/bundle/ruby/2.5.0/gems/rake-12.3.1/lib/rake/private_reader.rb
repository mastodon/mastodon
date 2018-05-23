# frozen_string_literal: true
module Rake

  # Include PrivateReader to use +private_reader+.
  module PrivateReader           # :nodoc: all

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Declare a list of private accessors
      def private_reader(*names)
        attr_reader(*names)
        private(*names)
      end
    end

  end
end
