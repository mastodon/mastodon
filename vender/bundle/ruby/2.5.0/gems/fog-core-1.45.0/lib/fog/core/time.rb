require "time"

module Fog
  class Time < ::Time
    DAYS = %w(Sun Mon Tue Wed Thu Fri Sat)
    MONTHS = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

    def self.now
      at(::Time.now - offset)
    end

    def self.now=(new_now)
      old_now = ::Time.now
      @offset = old_now - new_now
      new_now
    end

    def self.offset
      @offset ||= 0
    end

    def to_date_header
      utc.strftime("#{DAYS[utc.wday]}, %d #{MONTHS[utc.month - 1]} %Y %H:%M:%S +0000")
    end

    def to_iso8601_basic
      utc.strftime("%Y%m%dT%H%M%SZ")
    end
  end
end
