# frozen_string_literal: true
module Hamlit
  class Error < StandardError
    attr_reader :line

    def initialize(message = nil, line = nil)
      super(message)
      @line = line
    end
  end

  class SyntaxError < Error; end
  class InternalError < Error; end
  class FilterNotFound < Error; end
end
