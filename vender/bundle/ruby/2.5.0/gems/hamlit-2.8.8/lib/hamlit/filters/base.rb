# frozen_string_literal: true
require 'hamlit/parser/haml_util'

module Hamlit
  class Filters
    class Base
      def initialize(options = {})
        @format = options[:format]
      end
    end
  end
end
