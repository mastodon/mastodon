# frozen_string_literal: true
module Rake

  # EarlyTime is a fake timestamp that occurs _before_ any other time value.
  class EarlyTime
    include Comparable
    include Singleton

    ##
    # The EarlyTime always comes before +other+!

    def <=>(other)
      -1
    end

    def to_s # :nodoc:
      "<EARLY TIME>"
    end
  end

  EARLY = EarlyTime.instance
end
