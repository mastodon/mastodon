# frozen_string_literal: true
module Rake
  # LateTime is a fake timestamp that occurs _after_ any other time value.
  class LateTime
    include Comparable
    include Singleton

    def <=>(other)
      1
    end

    def to_s
      "<LATE TIME>"
    end
  end

  LATE = LateTime.instance
end
