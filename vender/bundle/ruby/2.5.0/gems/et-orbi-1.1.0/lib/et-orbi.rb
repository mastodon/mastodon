
require 'date' if RUBY_VERSION < '1.9.0'
require 'time'

require 'tzinfo'


module EtOrbi

  VERSION = '1.1.0'

  #
  # module methods

  class << self

    def now(zone=nil)

      EoTime.new(Time.now.to_f, zone)
    end

    def parse(str, opts={})

      if defined?(::Chronic) && t = ::Chronic.parse(str, opts)
        return EoTime.new(t, nil)
      end

      #rold = RUBY_VERSION < '1.9.0'
      #rold = RUBY_VERSION < '2.0.0'
      begin
        DateTime.parse(str)
      rescue
        fail ArgumentError, "No time information in #{str.inspect}"
      end #if rold
        #
        # is necessary since Time.parse('xxx') in Ruby < 1.9 yields `now`

      str_zone = get_tzone(list_iso8601_zones(str).last)
#p [ :parse, str, str_zone ]
#p ENV['TZ']

#p [ :parse, :oz, opts[:zone] ]
#p [ :parse, :sz, str_zone ]
#p [ :parse, :foz, find_olson_zone(str) ]
#p [ :parse, :ltz, local_tzone ]
      zone =
        opts[:zone] ||
        str_zone ||
        find_olson_zone(str) ||
        local_tzone
#p [ :parse, :zone, zone ]

      str = str.sub(zone.name, '') unless zone.name.match(/\A[-+]/)
        #
        # for 'Sun Nov 18 16:01:00 Asia/Singapore 2012',
        # although where does rufus-scheduler have it from?

      local = Time.parse(str)
#p [ :parse, :local, local, local.zone ]

      secs =
        if str_zone
          local.to_f
        else
          zone.local_to_utc(local).to_f
        end
#p [ :parse, :secs, secs ]

      EoTime.new(secs, zone)
    end

    def make_time(*a)

#p [ :mt, a ]
      zone = a.length > 1 ? get_tzone(a.last) : nil
      a.pop if zone
#p [ :mt, zone ]

      o = a.length > 1 ? a : a.first
#p [ :mt, :o, o ]

      case o
      when Time then make_from_time(o, zone)
      when Date then make_from_date(o, zone)
      when Array then make_from_array(o, zone)
      when String then make_from_string(o, zone)
      when Numeric then make_from_numeric(o, zone)
      when ::EtOrbi::EoTime then make_from_eotime(o, zone)
      else fail ArgumentError.new(
        "Cannot turn #{o.inspect} to a ::EtOrbi::EoTime instance")
      end
    end

    def make_from_time(t, zone)

      z =
        zone ||
        get_as_tzone(t) ||
        get_tzone(t.zone) ||
        get_local_tzone(t)

      z ||= t.zone
        # pass the abbreviation anyway,
        # it will be used in resulting the error message

      EoTime.new(t.to_f, z)
    end

    def make_from_date(d, zone)

      make_from_time(
        d.respond_to?(:to_time) ?
        d.to_time :
        Time.parse(d.strftime('%Y-%m-%d %H:%M:%S')),
        zone)
    end

    def make_from_array(a, zone)

      t = Time.utc(*a)
      s = t.strftime("%Y-%m-%d %H:%M:%S.#{'%06d' % t.usec}")

      make_from_string(s, zone)
    end

    def make_from_string(s, zone)

      parse(s, zone: zone)
    end

    def make_from_numeric(f, zone)

      EoTime.new(Time.now.to_f + f, zone)
    end

    def make_from_eotime(eot, zone)

      return eot if zone == nil || zone == eot.zone
      EoTime.new(eot.to_f, zone)
    end

    def get_tzone(o)

      return o if o.is_a?(::TZInfo::Timezone)
      return nil if o == nil
      return local_tzone if o == :local
      return ::TZInfo::Timezone.get('Zulu') if o == 'Z'
      return o.tzinfo if o.respond_to?(:tzinfo)

      o = to_offset(o) if o.is_a?(Numeric)

      return nil unless o.is_a?(String)

      (@custom_tz_cache ||= {})[o] ||
      get_offset_tzone(o) ||
      (::TZInfo::Timezone.get(o) rescue nil)
    end

    def local_tzone

      @local_tzone_tz ||= nil
      @local_tzone_loaded_at ||= nil

      @local_tzone = nil \
        if @local_tzone_loaded_at && (Time.now > @local_tzone_loaded_at + 1800)
      @local_tzone = nil \
        if @local_tzone_tz != ENV['TZ']

      @local_tzone ||=
        begin
          @local_tzone_tz = ENV['TZ']
          @local_tzone_loaded_at = Time.now
          determine_local_tzone
        end
    end

    def render_nozone_time(seconds)

      t =
        Time.utc(0) + seconds
      ts =
        t.strftime('%Y-%m-%d %H:%M:%S') +
        ".#{(seconds % 1).to_s.split('.').last}"
      z =
        EtOrbi.local_tzone ?
        EtOrbi.local_tzone.period_for_local(t).abbreviation.to_s :
        nil

      "(secs:#{seconds},utc~:#{ts.inspect},ltz~:#{z.inspect})"
    end

    def platform_info

      etos = Proc.new { |k, v| "#{k}:#{v.inspect}" }

      '(' +
        {
          'etz' => ENV['TZ'],
          'tnz' => Time.now.zone,
          'tzid' => defined?(TZInfo::Data),
          'rv' => RUBY_VERSION,
          'rp' => RUBY_PLATFORM,
          'eov' => EtOrbi::VERSION,
          'rorv' => (Rails::VERSION::STRING rescue nil),
          'astz' => ([ Time.zone.class, Time.zone.tzinfo.name ] rescue nil),
        }.collect(&etos).join(',') + ',' +
        gather_tzs.collect(&etos).join(',') +
      ')'
    end

    alias make make_time

    # For `make info`
    #
    def _make_info

      puts render_nozone_time(Time.now.to_f)
      puts platform_info
    end

    protected

    def get_local_tzone(t)

      #lt = local_tzone
      #lp = lt.period_for_local(t)
      #ab = lp.abbreviation.to_s
      #
      #return lt \
      #  if ab == t.zone
      #return lt \
      #  if ab.match(/\A[-+]\d{2}(:?\d{2})?\z/) && lp.utc_offset == t.utc_offset
      #
      #nil
        #
        # keep that in the fridge for now

      l = Time.local(t.year, t.month, t.day, t.hour, t.min, t.sec, t.usec)

      t.zone == l.zone ? local_tzone : nil
    end

    def get_as_tzone(t)

      t.respond_to?(:time_zone) ? t.time_zone : nil
    end
  end

  # Our EoTime class (which quacks like a ::Time).
  #
  # An EoTime instance should respond to most of the methods ::Time instances
  # respond to. If a method is missing, feel free to open an issue to
  # ask (politely) for it. If it makes sense, it'll get added, else
  # a workaround will get suggested.
  # The immediate workaround is to call #to_t on the EoTime instance to get
  # equivalent ::Time instance in the local, current, timezone.
  #
  class EoTime

    #
    # class methods

    class << self

      def now(zone=nil)

        EtOrbi.now(zone)
      end

      def parse(str, opts={})

        EtOrbi.parse(str, opts)
      end

      def get_tzone(o)

        EtOrbi.get_tzone(o)
      end

      def local_tzone

        EtOrbi.local_tzone
      end

      def platform_info

        EtOrbi.platform_info
      end

      def make(o)

        EtOrbi.make_time(o)
      end

      def utc(*a)

        EtOrbi.make_from_array(a, EtOrbi.get_tzone('UTC'))
      end

      def local(*a)

        EtOrbi.make_from_array(a, EtOrbi.local_tzone)
      end
    end

    #
    # instance methods

    attr_reader :seconds
    attr_reader :zone

    def initialize(s, zone)

      @seconds = s.to_f
      @zone = self.class.get_tzone(zone || :local)

      fail ArgumentError.new(
        "Cannot determine timezone from #{zone.inspect}" +
        "\n#{EtOrbi.render_nozone_time(s)}" +
        "\n#{EtOrbi.platform_info.sub(',debian:', ",\ndebian:")}" +
        "\nTry setting `ENV['TZ'] = 'Continent/City'` in your script " +
        "(see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)" +
        (defined?(TZInfo::Data) ? '' : "\nand adding gem 'tzinfo-data'")
      ) unless @zone

      @time = nil # cache for #to_time result
    end

    def seconds=(f)

      @time = nil
      @seconds = f
    end

    def zone=(z)

      @time = nil
      @zone = self.class.get_tzone(zone || :current)
    end

    # Returns this ::EtOrbi::EoTime as a ::Time instance
    # in the current UTC timezone.
    #
    def utc

      Time.utc(1970, 1, 1) + @seconds
    end

    # Returns true if this ::EtOrbi::EoTime instance timezone is UTC.
    # Returns false else.
    #
    def utc?

      %w[ zulu utc gmt ].include?(@zone.canonical_identifier.downcase)
    end

    alias getutc utc
    alias getgm utc
    alias to_utc_time utc

    def to_f

      @seconds
    end

    def to_i

      @seconds.to_i
    end

    def strftime(format)

      format = format.gsub(/%(\/?Z|:{0,2}z)/) { |f| strfz(f) }

      to_time.strftime(format)
    end

    # Returns this ::EtOrbi::EoTime as a ::Time instance
    # in the current timezone.
    #
    # Has a #to_t alias.
    #
    def to_local_time

      Time.at(@seconds)
    end

    alias to_t to_local_time

    def is_dst?

      @zone.period_for_utc(utc).std_offset != 0
    end
    alias isdst is_dst?

    def to_debug_s

      uo = self.utc_offset
      uos = uo < 0 ? '-' : '+'
      uo = uo.abs
      uoh, uom = [ uo / 3600, uo % 3600 ]

      [
        'ot',
        self.strftime('%Y-%m-%d %H:%M:%S'),
        "%s%02d:%02d" % [ uos, uoh, uom ],
        "dst:#{self.isdst}"
      ].join(' ')
    end

    def utc_offset

      @zone.period_for_utc(utc).utc_offset
    end

    %w[
      year month day wday hour min sec usec asctime
    ].each do |m|
      define_method(m) { to_time.send(m) }
    end

    def ==(o)

      o.is_a?(EoTime) &&
      o.seconds == @seconds &&
      (o.zone == @zone || o.zone.current_period == @zone.current_period)
    end
    #alias eql? == # FIXME see Object#== (ri)

    def >(o); @seconds > _to_f(o); end
    def >=(o); @seconds >= _to_f(o); end
    def <(o); @seconds < _to_f(o); end
    def <=(o); @seconds <= _to_f(o); end
    def <=>(o); @seconds <=> _to_f(o); end

    def add(t); @time = nil; @seconds += t.to_f; self; end
    def subtract(t); @time = nil; @seconds -= t.to_f; self; end

    def +(t); inc(t, 1); end
    def -(t); inc(t, -1); end

    WEEK_S = 7 * 24 * 3600

    def monthdays

      date = to_time

      pos = 1
      d = self.dup

      loop do
        d.add(-WEEK_S)
        break if d.month != date.month
        pos = pos + 1
      end

      neg = -1
      d = self.dup

      loop do
        d.add(WEEK_S)
        break if d.month != date.month
        neg = neg - 1
      end

      [ "#{date.wday}##{pos}", "#{date.wday}##{neg}" ]
    end

    def to_s

      strftime('%Y-%m-%d %H:%M:%S %z')
    end

    def iso8601(fraction_digits=0)

      s = (fraction_digits || 0) > 0 ? ".%#{fraction_digits}N" : ''
      strftime("%Y-%m-%dT%H:%M:%S#{s}%:z")
    end

    # Debug current time by showing local time / delta / utc time
    # for example: "0120-7(0820)"
    #
    def to_utc_comparison_s

      per = @zone.period_for_utc(utc)
      off = per.utc_total_offset

      off = off / 3600
      off = off >= 0 ? "+#{off}" : off.to_s

      strftime('%H%M') + off + utc.strftime('(%H%M)')
    end

    def to_time_s

      strftime("%H:%M:%S.#{'%06d' % usec}")
    end

    def inc(t, dir=1)

      case t
      when Numeric
        nt = self.dup
        nt.seconds += dir * t.to_f
        nt
      when ::Time, ::EtOrbi::EoTime
        fail ArgumentError.new(
          "Cannot add #{t.class} to EoTime") if dir > 0
        @seconds + dir * t.to_f
      else
        fail ArgumentError.new(
          "Cannot call add or subtract #{t.class} to EoTime instance")
      end
    end

    def localtime(zone=nil)

      EoTime.new(self.to_f, zone)
    end

    alias translate localtime

    def wday_in_month

      [ count_weeks(-1), - count_weeks(1) ]
    end

    protected

    # Returns a Ruby Time instance.
    #
    # Warning: the timezone of that Time instance will be UTC when used with
    # TZInfo < 2.0.0.
    #
    def to_time

      @time ||= begin; u = utc; @zone.utc_to_local(u); end
    end

    def count_weeks(dir)

      c = 0
      t = self
      until t.month != self.month
        c += 1
        t += dir * (7 * 24 * 3600)
      end

      c
    end

    def strfz(code)

      return @zone.name if code == '%/Z'

      per = @zone.period_for_utc(utc)

      return per.abbreviation.to_s if code == '%Z'

      off = per.utc_total_offset
        #
      sn = off < 0 ? '-' : '+'; off = off.abs
      hr = off / 3600
      mn = (off % 3600) / 60
      sc = 0

      if @zone.name == 'UTC'
        'Z' # align on Ruby ::Time#iso8601
      elsif code == '%z'
        '%s%02d%02d' % [ sn, hr, mn ]
      elsif code == '%:z'
        '%s%02d:%02d' % [ sn, hr, mn ]
      else
        '%s%02d:%02d:%02d' % [ sn, hr, mn, sc ]
      end
    end

    def _to_f(o)

      fail ArgumentError(
        "Comparison of EoTime with #{o.inspect} failed"
      ) unless o.is_a?(EoTime) || o.is_a?(Time)

      o.to_f
    end
  end

  class << self

    #
    # extra public methods

    # https://en.wikipedia.org/wiki/ISO_8601
    # Postel's law applies
    #
    def list_iso8601_zones(s)

      s.scan(
        %r{
          (?<=:\d\d)
          \s*
          (?:
            [-+]
            (?:[0-1][0-9]|2[0-4])
            (?:(?::)?(?:[0-5][0-9]|60))?
            (?![-+])
            |
            Z
          )
        }x
        ).collect(&:strip)
    end

    def list_olson_zones(s)

      s.scan(
        %r{
          (?<=\s|\A)
          (?:[A-Za-z][A-Za-z0-9+_-]+)
          (?:\/(?:[A-Za-z][A-Za-z0-9+_-]+)){0,2}
        }x)
    end

    def find_olson_zone(str)

      list_olson_zones(str).each { |s| z = get_tzone(s); return z if z }
      nil
    end

    def determine_local_tzone

      etz = ENV['TZ']

      tz = ::TZInfo::Timezone.get(etz) rescue nil
      return tz if tz

      if Time.respond_to?(:zone) && Time.zone.respond_to?(:tzinfo)
        tz = Time.zone.tzinfo
        return tz if tz
      end

      tz = ::TZInfo::Timezone.get(os_tz) rescue nil
      return tz if tz

      tzs = determine_local_tzones
      (etz && tzs.find { |z| z.name == etz }) || tzs.first
    end

    def os_tz

      debian_tz || centos_tz || osx_tz
    end

    #
    # protected module methods

    protected

    def to_offset(n)

      i = n.to_i
      sn = i < 0 ? '-' : '+'; i = i.abs
      hr = i / 3600; mn = i % 3600; sc = i % 60
      (sc > 0 ? "%s%02d:%02d:%02d" : "%s%02d:%02d") % [ sn, hr, mn, sc ]
    end

    def get_offset_tzone(str)

      # custom timezones, no DST, just an offset, like "+08:00" or "-01:30"

      m = str.match(/\A([+-][0-1][0-9]):?([0-5][0-9])?\z/)
      return nil unless m

      hr = m[1].to_i
      mn = m[2].to_i

      hr = nil if hr.abs > 11
      hr = nil if mn > 59
      mn = -mn if hr && hr < 0

      return (
        @custom_tz_cache[str] = create_offset_tzone(hr * 3600 + mn * 60, str)
      ) if hr

      nil
    end

    if defined? TZInfo::DataSources::ConstantOffsetDataTimezoneInfo
      # TZInfo >= 2.0.0

      def create_offset_tzone(utc_off, id)

        off = TZInfo::TimezoneOffset.new(utc_off, 0, id)
        tzi = TZInfo::DataSources::ConstantOffsetDataTimezoneInfo.new(id, off)
        tzi.create_timezone
      end

    else
      # TZInfo < 2.0.0

      def create_offset_tzone(utc_off, id)

        tzi = TZInfo::TransitionDataTimezoneInfo.new(id)
        tzi.offset(id, utc_off, 0, id)
        tzi.create_timezone
      end

    end

    def determine_local_tzones

      tabbs = (-6..5)
        .collect { |i| (Time.now + i * 30 * 24 * 3600).zone }
        .uniq
        .sort

      t = Time.now
      #tu = t.dup.utc # /!\ dup is necessary, #utc modifies its target

      twin = Time.utc(t.year, 1, 1) # winter
      tsum = Time.utc(t.year, 7, 1) # summer

      ::TZInfo::Timezone.all.select do |tz|

        pabbs =
          [
            tz.period_for_utc(twin).abbreviation.to_s,
            tz.period_for_utc(tsum).abbreviation.to_s
          ].uniq.sort

        pabbs == tabbs
      end
    end

    #
    # system tz determination

    def debian_tz

      path = '/etc/timezone'

      File.exist?(path) ? File.read(path).strip : nil
    rescue; nil; end

    def centos_tz

      path = '/etc/sysconfig/clock'

      File.open(path, 'rb') do |f|
        until f.eof?
          if m = f.readline.match(/ZONE="([^"]+)"/); return m[1]; end
        end
      end if File.exist?(path)

      nil
    rescue; nil; end

    def osx_tz

      path = '/etc/localtime'

      File.symlink?(path) ?
        File.readlink(path).split('/')[4..-1].join('/') :
        nil
    rescue; nil; end

    def gather_tzs

      { :debian => debian_tz, :centos => centos_tz, :osx => osx_tz }
    end
  end

  #def in_zone(&block)
  #
  #  current_timezone = ENV['TZ']
  #  ENV['TZ'] = @zone
  #
  #  block.call
  #
  #ensure
  #
  #  ENV['TZ'] = current_timezone
  #end
    #
    # kept around as a (thread-unsafe) relic
end

