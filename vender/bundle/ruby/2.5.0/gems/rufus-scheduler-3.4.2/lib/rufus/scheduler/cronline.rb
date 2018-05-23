

class Rufus::Scheduler

  #
  # A 'cron line' is a line in the sense of a crontab
  # (man 5 crontab) file line.
  #
  class CronLine

    # The max number of years in the future or the past before giving up
    # searching for #next_time or #previous_time respectively
    #
    NEXT_TIME_MAX_YEARS = 14

    # The string used for creating this cronline instance.
    #
    attr_reader :original
    attr_reader :original_timezone

    attr_reader :seconds
    attr_reader :minutes
    attr_reader :hours
    attr_reader :days
    attr_reader :months
    #attr_reader :monthdays # reader defined below
    attr_reader :weekdays
    attr_reader :timezone

    def initialize(line)

      fail ArgumentError.new(
        "not a string: #{line.inspect}"
      ) unless line.is_a?(String)

      @original = line
      @original_timezone = nil

      items = line.split

      if @timezone = EoTime.get_tzone(items.last)
        @original_timezone = items.pop
      else
        @timezone = EoTime.local_tzone
      end

      fail ArgumentError.new(
        "not a valid cronline : '#{line}'"
      ) unless items.length == 5 or items.length == 6

      offset = items.length - 5

      @seconds = offset == 1 ? parse_item(items[0], 0, 59) : [ 0 ]
      @minutes = parse_item(items[0 + offset], 0, 59)
      @hours = parse_item(items[1 + offset], 0, 24)
      @days = parse_item(items[2 + offset], -30, 31)
      @months = parse_item(items[3 + offset], 1, 12)
      @weekdays, @monthdays = parse_weekdays(items[4 + offset])

      [ @seconds, @minutes, @hours, @months ].each do |es|

        fail ArgumentError.new(
          "invalid cronline: '#{line}'"
        ) if es && es.find { |e| ! e.is_a?(Integer) }
      end

      if @days && @days.include?(0) # gh-221

        fail ArgumentError.new('invalid day 0 in cronline')
      end
    end

    # Returns true if the given time matches this cron line.
    #
    def matches?(time)

        # FIXME Don't create a new EoTime if time is already a EoTime in same
        #       zone ...
        #       Wait, this seems only used in specs...
      t = EoTime.new(time.to_f, @timezone)

      return false unless sub_match?(t, :sec, @seconds)
      return false unless sub_match?(t, :min, @minutes)
      return false unless sub_match?(t, :hour, @hours)
      return false unless date_match?(t)
      true
    end

    # Returns the next time that this cron line is supposed to 'fire'
    #
    # This is raw, 3 secs to iterate over 1 year on my macbook :( brutal.
    # (Well, I was wrong, takes 0.001 sec on 1.8.7 and 1.9.1)
    #
    # This method accepts an optional Time parameter. It's the starting point
    # for the 'search'. By default, it's Time.now
    #
    # Note that the time instance returned will be in the same time zone that
    # the given start point Time (thus a result in the local time zone will
    # be passed if no start time is specified (search start time set to
    # Time.now))
    #
    #   Rufus::Scheduler::CronLine.new('30 7 * * *').next_time(
    #     Time.mktime(2008, 10, 24, 7, 29))
    #   #=> Fri Oct 24 07:30:00 -0500 2008
    #
    #   Rufus::Scheduler::CronLine.new('30 7 * * *').next_time(
    #     Time.utc(2008, 10, 24, 7, 29))
    #   #=> Fri Oct 24 07:30:00 UTC 2008
    #
    #   Rufus::Scheduler::CronLine.new('30 7 * * *').next_time(
    #     Time.utc(2008, 10, 24, 7, 29)).localtime
    #   #=> Fri Oct 24 02:30:00 -0500 2008
    #
    # (Thanks to K Liu for the note and the examples)
    #
    def next_time(from=EoTime.now)

      nt = nil
      zt = EoTime.new(from.to_i + 1, @timezone)
      maxy = from.year + NEXT_TIME_MAX_YEARS

      loop do

        nt = zt.dup

        fail RangeError.new(
          "failed to reach occurrence within " +
          "#{NEXT_TIME_MAX_YEARS} years for '#{original}'"
        ) if nt.year > maxy

        unless date_match?(nt)
          zt.add((24 - nt.hour) * 3600 - nt.min * 60 - nt.sec)
          next
        end
        unless sub_match?(nt, :hour, @hours)
          zt.add((60 - nt.min) * 60 - nt.sec)
          next
        end
        unless sub_match?(nt, :min, @minutes)
          zt.add(60 - nt.sec)
          next
        end
        unless sub_match?(nt, :sec, @seconds)
          zt.add(next_second(nt))
          next
        end

        break
      end

      nt
    end

    # Returns the previous time the cronline matched. It's like next_time, but
    # for the past.
    #
    def previous_time(from=EoTime.now)

      pt = nil
      zt = EoTime.new(from.to_i - 1, @timezone)
      miny = from.year - NEXT_TIME_MAX_YEARS

      loop do

        pt = zt.dup

        fail RangeError.new(
          "failed to reach occurrence within " +
          "#{NEXT_TIME_MAX_YEARS} years for '#{original}'"
        ) if pt.year < miny

        unless date_match?(pt)
          zt.subtract(pt.hour * 3600 + pt.min * 60 + pt.sec + 1)
          next
        end
        unless sub_match?(pt, :hour, @hours)
          zt.subtract(pt.min * 60 + pt.sec + 1)
          next
        end
        unless sub_match?(pt, :min, @minutes)
          zt.subtract(pt.sec + 1)
          next
        end
        unless sub_match?(pt, :sec, @seconds)
          zt.subtract(prev_second(pt))
          next
        end

        break
      end

      pt
    end

    # Returns an array of 6 arrays (seconds, minutes, hours, days,
    # months, weekdays).
    # This method is mostly used by the cronline specs.
    #
    def to_a

      [
        toa(@seconds),
        toa(@minutes),
        toa(@hours),
        toa(@days),
        toa(@months),
        toa(@weekdays),
        toa(@monthdays),
        @timezone.name
      ]
    end
    alias to_array to_a

    # Returns a quickly computed approximation of the frequency for this
    # cron line.
    #
    # #brute_frequency, on the other hand, will compute the frequency by
    # examining a whole year, that can take more than seconds for a seconds
    # level cron...
    #
    def frequency

      return brute_frequency unless @seconds && @seconds.length > 1

      secs = toa(@seconds)

      secs[1..-1].inject([ secs[0], 60 ]) { |(prev, delta), sec|
        d = sec - prev
        [ sec, d < delta ? d : delta ]
      }[1]
    end

    # Caching facility. Currently only used for brute frequencies.
    #
    @cache = {}; class << self; attr_reader :cache; end

    # Returns the shortest delta between two potential occurrences of the
    # schedule described by this cronline.
    #
    # .
    #
    # For a simple cronline like "*/5 * * * *", obviously the frequency is
    # five minutes. Why does this method look at a whole year of #next_time ?
    #
    # Consider "* * * * sun#2,sun#3", the computed frequency is 1 week
    # (the shortest delta is the one between the second sunday and the third
    # sunday). This method takes no chance and runs next_time for the span
    # of a whole year and keeps the shortest.
    #
    # Of course, this method can get VERY slow if you call on it a second-
    # based cronline...
    #
    def brute_frequency

      key = "brute_frequency:#{@original}"

      delta = self.class.cache[key]
      return delta if delta

      delta = 366 * DAY_S

      t0 = previous_time(Time.local(2000, 1, 1))

      loop do

        break if delta <= 1
        break if delta <= 60 && @seconds && @seconds.size == 1

#st = Time.now
        t1 = next_time(t0)
#p Time.now - st
        d = t1 - t0
        delta = d if d < delta
        break if @months.nil? && t1.month == 2
        break if @months.nil? && @days.nil? && t1.day == 2
        break if @months.nil? && @days.nil? && @hours.nil? && t1.hour == 1
        break if @months.nil? && @days.nil? && @hours.nil? && @minutes.nil? && t1.min == 1
        break if t1.year >= 2001

        t0 = t1
      end

      self.class.cache[key] = delta
    end

    def next_second(time)

      secs = toa(@seconds)

      return secs.first + 60 - time.sec if time.sec > secs.last

      secs.shift while secs.first < time.sec

      secs.first - time.sec
    end

    def prev_second(time)

      secs = toa(@seconds)

      return time.sec + 60 - secs.last if time.sec < secs.first

      secs.pop while time.sec < secs.last

      time.sec - secs.last
    end

    protected

    def sc_sort(a)

      a.sort_by { |e| e.is_a?(String) ? 61 : e.to_i }
    end

    if RUBY_VERSION >= '1.9'
      def toa(item)
        item == nil ? nil : item.to_a
      end
    else
      def toa(item)
        item.is_a?(Set) ? sc_sort(item.to_a) : item
      end
    end

    WEEKDAYS = %w[ sun mon tue wed thu fri sat ]
    DAY_S = 24 * 3600

    def parse_weekdays(item)

      return nil if item == '*'

      weekdays = nil
      monthdays = nil

      item.downcase.split(',').each do |it|

        WEEKDAYS.each_with_index { |a, i| it.gsub!(/#{a}/, i.to_s) }

        it = it.gsub(/([^#])l/, '\1#-1')
          # "5L" == "5#-1" == the last Friday

        if m = it.match(/\A(.+)#(l|-?[12345])\z/)

          fail ArgumentError.new(
            "ranges are not supported for monthdays (#{it})"
          ) if m[1].index('-')

          it = it.gsub(/#l/, '#-1')

          (monthdays ||= []) << it

        else

          fail ArgumentError.new(
            "invalid weekday expression (#{item})"
          ) if it !~ /\A0*[0-7](-0*[0-7])?\z/

          its = it.index('-') ? parse_range(it, 0, 7) : [ Integer(it) ]
          its = its.collect { |i| i == 7 ? 0 : i }

          (weekdays ||= []).concat(its)
        end
      end

      weekdays = weekdays.uniq.sort if weekdays

      [ weekdays, monthdays ]
    end

    def parse_item(item, min, max)

      return nil if item == '*'

      r = item.split(',').map { |i| parse_range(i.strip, min, max) }.flatten

      fail ArgumentError.new(
        "found duplicates in #{item.inspect}"
      ) if r.uniq.size < r.size

      r = sc_sort(r)

      Set.new(r)
    end

    RANGE_REGEX = /\A(\*|-?\d{1,2})(?:-(-?\d{1,2}))?(?:\/(\d{1,2}))?\z/

    def parse_range(item, min, max)

      return %w[ L ] if item == 'L'

      item = '*' + item if item[0, 1] == '/'

      m = item.match(RANGE_REGEX)

      fail ArgumentError.new(
        "cannot parse #{item.inspect}"
      ) unless m

      mmin = min == -30 ? 1 : min # days

      sta = m[1]
      sta = sta == '*' ? mmin : sta.to_i

      edn = m[2]
      edn = edn ? edn.to_i : sta
      edn = max if m[1] == '*'

      inc = m[3]
      inc = inc ? inc.to_i : 1

      fail ArgumentError.new(
        "#{item.inspect} positive/negative ranges not allowed"
      ) if (sta < 0 && edn > 0) || (sta > 0 && edn < 0)

      fail ArgumentError.new(
        "#{item.inspect} descending day ranges not allowed"
      ) if min == -30 && sta > edn

      fail ArgumentError.new(
        "#{item.inspect} is not in range #{min}..#{max}"
      ) if sta < min || edn > max

      fail ArgumentError.new(
        "#{item.inspect} increment must be greater than zero"
      ) if inc == 0

      r = []
      val = sta

      loop do
        v = val
        v = 0 if max == 24 && v == 24 # hours
        r << v
        break if inc == 1 && val == edn
        val += inc
        break if inc > 1 && val > edn
        val = min if val > max
      end

      r.uniq
    end

    # FIXME: Eventually split into day_match?, hour_match? and monthdays_match?o
    #
    def sub_match?(time, accessor, values)

      return true if values.nil?

      value = time.send(accessor)

      if accessor == :day

        values.each do |v|
          return true if v == 'L' && (time + DAY_S).day == 1
          return true if v.to_i < 0 && (time + (1 - v) * DAY_S).day == 1
        end
      end

      if accessor == :hour

        return true if value == 0 && values.include?(24)
      end

      if accessor == :monthdays

        return true if (values & value).any?
      end

      values.include?(value)
    end

#    def monthday_match?(zt, values)
#
#      return true if values.nil?
#
#      today_values = monthdays(zt)
#
#      (today_values & values).any?
#    end

    def date_match?(zt)

      return false unless sub_match?(zt, :day, @days)
      return false unless sub_match?(zt, :month, @months)

      return true if (
        (@weekdays && @monthdays) &&
        (sub_match?(zt, :wday, @weekdays) ||
         sub_match?(zt, :monthdays, @monthdays)))

      return false unless sub_match?(zt, :wday, @weekdays)
      return false unless sub_match?(zt, :monthdays, @monthdays)

      true
    end
  end
end

