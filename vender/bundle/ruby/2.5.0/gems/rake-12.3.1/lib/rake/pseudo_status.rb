# frozen_string_literal: true
module Rake

  ##
  # Exit status class for times the system just gives us a nil.
  class PseudoStatus # :nodoc: all
    attr_reader :exitstatus

    def initialize(code=0)
      @exitstatus = code
    end

    def to_i
      @exitstatus << 8
    end

    def >>(n)
      to_i >> n
    end

    def stopped?
      false
    end

    def exited?
      true
    end
  end

end
