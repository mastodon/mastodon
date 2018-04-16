
require 'active_support/time'

module Oj

  # Exists only to handle the ActiveSupport::TimeWithZone.
  class ActiveSupportHelper

    def self.createTimeWithZone(utc, zone)
      ActiveSupport::TimeWithZone.new(utc - utc.gmt_offset, ActiveSupport::TimeZone[zone])
    end
  end

end

Oj.register_odd(ActiveSupport::TimeWithZone, Oj::ActiveSupportHelper, :createTimeWithZone, :utc, 'time_zone.name')

# This is a hack to work around an oddness with DateTime and the ActiveSupport
# that causes a hang when some methods are called from C. Hour, min(ute),
# sec(ond) and other methods are special but they can be called from C until
# activesupport/time is required. After that they can not be even though
# resond_to? returns true. By defining methods to call super the problem goes
# away. There is obviously some magic going on under the covers that I don't
# understand.
class DateTime
  def hour()
    super
  end
  def min()
    super
  end
  def sec()
    super
  end
  def sec_fraction()
    super
  end
  def offset()
    super
  end
end
