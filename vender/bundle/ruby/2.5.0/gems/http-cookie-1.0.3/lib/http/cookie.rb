# :markup: markdown
require 'http/cookie/version'
require 'time'
require 'uri'
require 'domain_name'
require 'http/cookie/ruby_compat'

module HTTP
  autoload :CookieJar, 'http/cookie_jar'
end

# This class is used to represent an HTTP Cookie.
class HTTP::Cookie
  # Maximum number of bytes per cookie (RFC 6265 6.1 requires 4096 at
  # least)
  MAX_LENGTH = 4096
  # Maximum number of cookies per domain (RFC 6265 6.1 requires 50 at
  # least)
  MAX_COOKIES_PER_DOMAIN = 50
  # Maximum number of cookies total (RFC 6265 6.1 requires 3000 at
  # least)
  MAX_COOKIES_TOTAL = 3000

  # :stopdoc:
  UNIX_EPOCH = Time.at(0)

  PERSISTENT_PROPERTIES = %w[
    name        value
    domain      for_domain  path
    secure      httponly
    expires     max_age
    created_at  accessed_at
  ]
  # :startdoc:

  # The cookie name.  It may not be nil or empty.
  #
  # Assign a string containing any of the following characters will
  # raise ArgumentError: control characters (`\x00-\x1F` and `\x7F`),
  # space and separators `,;\"=`.
  #
  # Note that RFC 6265 4.1.1 lists more characters disallowed for use
  # in a cookie name, which are these: `<>@:/[]?{}`.  Using these
  # characters will reduce interoperability.
  #
  # :attr_accessor: name

  # The cookie value.
  #
  # Assign a string containing a control character (`\x00-\x1F` and
  # `\x7F`) will raise ArgumentError.
  #
  # Assigning nil sets the value to an empty string and the expiration
  # date to the Unix epoch.  This is a handy way to make a cookie for
  # expiration.
  #
  # Note that RFC 6265 4.1.1 lists more characters disallowed for use
  # in a cookie value, which are these: ` ",;\`.  Using these
  # characters will reduce interoperability.
  #
  # :attr_accessor: value

  # The cookie domain.
  #
  # Setting a domain with a leading dot implies that the #for_domain
  # flag should be turned on.  The setter accepts a DomainName object
  # as well as a string-like.
  #
  # :attr_accessor: domain

  # The path attribute value.
  #
  # The setter treats an empty path ("") as the root path ("/").
  #
  # :attr_accessor: path

  # The origin of the cookie.
  #
  # Setting this will initialize the #domain and #path attribute
  # values if unknown yet.  If the cookie already has a domain value
  # set, it is checked against the origin URL to see if the origin is
  # allowed to issue a cookie of the domain, and ArgumentError is
  # raised if the check fails.
  #
  # :attr_accessor: origin

  # The Expires attribute value as a Time object.
  #
  # The setter method accepts a Time object, a string representation
  # of date/time that Time.parse can understand, or `nil`.
  #
  # Setting this value resets #max_age to nil.  When #max_age is
  # non-nil, #expires returns `created_at + max_age`.
  #
  # :attr_accessor: expires

  # The Max-Age attribute value as an integer, the number of seconds
  # before expiration.
  #
  # The setter method accepts an integer, or a string-like that
  # represents an integer which will be stringified and then
  # integerized using #to_i.
  #
  # This value is reset to nil when #expires= is called.
  #
  # :attr_accessor: max_age

  # :call-seq:
  #     new(name, value = nil)
  #     new(name, value = nil, **attr_hash)
  #     new(**attr_hash)
  #
  # Creates a cookie object.  For each key of `attr_hash`, the setter
  # is called if defined and any error (typically ArgumentError or
  # TypeError) that is raised will be passed through.  Each key can be
  # either a downcased symbol or a string that may be mixed case.
  # Support for the latter may, however, be obsoleted in future when
  # Ruby 2.0's keyword syntax is adopted.
  #
  # If `value` is omitted or it is nil, an expiration cookie is
  # created unless `max_age` or `expires` (`expires_at`) is given.
  #
  # e.g.
  #
  #     new("uid", "a12345")
  #     new("uid", "a12345", :domain => 'example.org',
  #                          :for_domain => true, :expired => Time.now + 7*86400)
  #     new("name" => "uid", "value" => "a12345", "Domain" => 'www.example.org')
  #
  def initialize(*args)
    @origin = @domain = @path =
      @expires = @max_age = nil
    @for_domain = @secure = @httponly = false
    @session = true
    @created_at = @accessed_at = Time.now
    case argc = args.size
    when 1
      if attr_hash = Hash.try_convert(args.last)
        args.pop
      else
        self.name, self.value = args # value is set to nil
        return
      end
    when 2..3
      if attr_hash = Hash.try_convert(args.last)
        args.pop
        self.name, value = args
      else
        argc == 2 or
          raise ArgumentError, "wrong number of arguments (#{argc} for 1-3)"
        self.name, self.value = args
        return
      end
    else
      raise ArgumentError, "wrong number of arguments (#{argc} for 1-3)"
    end
    for_domain = false
    domain = max_age = origin = nil
    attr_hash.each_pair { |okey, val|
      case key ||= okey
      when :name
        self.name = val
      when :value
        value = val
      when :domain
        domain = val
      when :path
        self.path = val
      when :origin
        origin = val
      when :for_domain, :for_domain?
        for_domain = val
      when :max_age
        # Let max_age take precedence over expires
        max_age = val
      when :expires, :expires_at
        self.expires = val unless max_age
      when :httponly, :httponly?
        @httponly = val
      when :secure, :secure?
        @secure = val
      when Symbol
        setter = :"#{key}="
        if respond_to?(setter)
          __send__(setter, val)
        else
          warn "unknown attribute name: #{okey.inspect}" if $VERBOSE
          next
        end
      when String
        warn "use downcased symbol for keyword: #{okey.inspect}" if $VERBOSE
        key = key.downcase.to_sym
        redo
      else
        warn "invalid keyword ignored: #{okey.inspect}" if $VERBOSE
        next
      end
    }
    if @name.nil?
      raise ArgumentError, "name must be specified"
    end
    @for_domain = for_domain
    self.domain = domain if domain
    self.origin = origin if origin
    self.max_age = max_age if max_age
    self.value = value.nil? && (@expires || @max_age) ? '' : value
  end

  autoload :Scanner, 'http/cookie/scanner'

  class << self
    # Tests if +target_path+ is under +base_path+ as described in RFC
    # 6265 5.1.4.  +base_path+ must be an absolute path.
    # +target_path+ may be empty, in which case it is treated as the
    # root path.
    #
    # e.g.
    #
    #         path_match?('/admin/', '/admin/index') == true
    #         path_match?('/admin/', '/Admin/index') == false
    #         path_match?('/admin/', '/admin/') == true
    #         path_match?('/admin/', '/admin') == false
    #
    #         path_match?('/admin', '/admin') == true
    #         path_match?('/admin', '/Admin') == false
    #         path_match?('/admin', '/admins') == false
    #         path_match?('/admin', '/admin/') == true
    #         path_match?('/admin', '/admin/index') == true
    def path_match?(base_path, target_path)
      base_path.start_with?('/') or return false
      # RFC 6265 5.1.4
      bsize = base_path.size
      tsize = target_path.size
      return bsize == 1 if tsize == 0 # treat empty target_path as "/"
      return false unless target_path.start_with?(base_path)
      return true if bsize == tsize || base_path.end_with?('/')
      target_path[bsize] == ?/
    end

    # Parses a Set-Cookie header value `set_cookie` assuming that it
    # is sent from a source URI/URL `origin`, and returns an array of
    # Cookie objects.  Parts (separated by commas) that are malformed
    # or considered unacceptable are silently ignored.
    #
    # If a block is given, each cookie object is passed to the block.
    #
    # Available option keywords are below:
    #
    # :created_at
    # : The creation time of the cookies parsed.
    #
    # :logger
    # : Logger object useful for debugging
    #
    # ### Compatibility Note for Mechanize::Cookie users
    #
    # * Order of parameters changed in HTTP::Cookie.parse:
    #
    #         Mechanize::Cookie.parse(uri, set_cookie[, log])
    #
    #         HTTP::Cookie.parse(set_cookie, uri[, :logger => # log])
    #
    # * HTTP::Cookie.parse does not accept nil for `set_cookie`.
    #
    # * HTTP::Cookie.parse does not yield nil nor include nil in an
    #   returned array.  It simply ignores unparsable parts.
    #
    # * HTTP::Cookie.parse is made to follow RFC 6265 to the extent
    #   not terribly breaking interoperability with broken
    #   implementations.  In particular, it is capable of parsing
    #   cookie definitions containing double-quotes just as naturally
    #   expected.
    def parse(set_cookie, origin, options = nil, &block)
      if options
        logger = options[:logger]
        created_at = options[:created_at]
      end
      origin = URI(origin)

      [].tap { |cookies|
        Scanner.new(set_cookie, logger).scan_set_cookie { |name, value, attrs|
          break if name.nil? || name.empty?

          begin
            cookie = new(name, value)
          rescue => e
            logger.warn("Invalid name or value: #{e}") if logger
            next
          end
          cookie.created_at = created_at if created_at
          attrs.each { |aname, avalue|
            begin
              case aname
              when 'domain'
                cookie.for_domain = true
                # The following may negate @for_domain if the value is
                # an eTLD or IP address, hence this order.
                cookie.domain = avalue
              when 'path'
                cookie.path = avalue
              when 'expires'
                # RFC 6265 4.1.2.2
                # The Max-Age attribute has precedence over the Expires
                # attribute.
                cookie.expires = avalue unless cookie.max_age
              when 'max-age'
                cookie.max_age = avalue
              when 'secure'
                cookie.secure = avalue
              when 'httponly'
                cookie.httponly = avalue
              end
            rescue => e
              logger.warn("Couldn't parse #{aname} '#{avalue}': #{e}") if logger
            end
          }

          cookie.origin = origin

          cookie.acceptable? or next

          yield cookie if block_given?

          cookies << cookie
        }
      }
    end

    # Takes an array of cookies and returns a string for use in the
    # Cookie header, like "name1=value2; name2=value2".
    def cookie_value(cookies)
      cookies.join('; ')
    end

    # Parses a Cookie header value into a hash of name-value string
    # pairs.  The first appearance takes precedence if multiple pairs
    # with the same name occur.
    def cookie_value_to_hash(cookie_value)
      {}.tap { |hash|
        Scanner.new(cookie_value).scan_cookie { |name, value|
          hash[name] ||= value
        }
      }
    end
  end

  attr_reader :name

  # See #name.
  def name= name
    name = (String.try_convert(name) or
      raise TypeError, "#{name.class} is not a String")
    if name.empty?
      raise ArgumentError, "cookie name cannot be empty"
    elsif name.match(/[\x00-\x20\x7F,;\\"=]/)
      raise ArgumentError, "invalid cookie name"
    end
    # RFC 6265 4.1.1
    # cookie-name may not match:
    # /[\x00-\x20\x7F()<>@,;:\\"\/\[\]?={}]/
    @name = name
  end

  attr_reader :value

  # See #value.
  def value= value
    if value.nil?
      self.expires = UNIX_EPOCH
      return @value = ''
    end
    value = (String.try_convert(value) or
      raise TypeError, "#{value.class} is not a String")
    if value.match(/[\x00-\x1F\x7F]/)
      raise ArgumentError, "invalid cookie value"
    end
    # RFC 6265 4.1.1
    # cookie-name may not match:
    # /[^\x21\x23-\x2B\x2D-\x3A\x3C-\x5B\x5D-\x7E]/
    @value = value
  end

  attr_reader :domain

  # See #domain.
  def domain= domain
    case domain
    when nil
      @for_domain = false
      if @origin
        @domain_name = DomainName.new(@origin.host)
        @domain = @domain_name.hostname
      else
        @domain_name = @domain = nil
      end
      return nil
    when DomainName
      @domain_name = domain
    else
      domain = (String.try_convert(domain) or
        raise TypeError, "#{domain.class} is not a String")
      if domain.start_with?('.')
        for_domain = true
        domain = domain[1..-1]
      end
      if domain.empty?
        return self.domain = nil
      end
      # Do we really need to support this?
      if domain.match(/\A([^:]+):[0-9]+\z/)
        domain = $1
      end
      @domain_name = DomainName.new(domain)
    end
    # RFC 6265 5.3 5.
    if domain_name.domain.nil? # a public suffix or IP address
      @for_domain = false
    else
      @for_domain = for_domain unless for_domain.nil?
    end
    @domain = @domain_name.hostname
  end

  # Returns the domain, with a dot prefixed only if the domain flag is
  # on.
  def dot_domain
    @for_domain ? '.' << @domain : @domain
  end

  # Returns the domain attribute value as a DomainName object.
  attr_reader :domain_name

  # The domain flag. (the opposite of host-only-flag)
  #
  # If this flag is true, this cookie will be sent to any host in the
  # \#domain, including the host domain itself.  If it is false, this
  # cookie will be sent only to the host indicated by the #domain.
  attr_accessor :for_domain
  alias for_domain? for_domain

  attr_reader :path

  # See #path.
  def path= path
    path = (String.try_convert(path) or
      raise TypeError, "#{path.class} is not a String")
    @path = path.start_with?('/') ? path : '/'
  end

  attr_reader :origin

  # See #origin.
  def origin= origin
    return origin if origin == @origin
    @origin.nil? or
      raise ArgumentError, "origin cannot be changed once it is set"
    # Delay setting @origin because #domain= or #path= may fail
    origin = URI(origin)
    if URI::HTTP === origin
      self.domain ||= origin.host
      self.path   ||= (origin + './').path
    end
    @origin = origin
  end

  # The secure flag. (secure-only-flag)
  #
  # A cookie with this flag on should only be sent via a secure
  # protocol like HTTPS.
  attr_accessor :secure
  alias secure? secure

  # The HttpOnly flag. (http-only-flag)
  #
  # A cookie with this flag on should be hidden from a client script.
  attr_accessor :httponly
  alias httponly? httponly

  # The session flag. (the opposite of persistent-flag)
  #
  # A cookie with this flag on should be hidden from a client script.
  attr_reader :session
  alias session? session

  def expires
    @expires or @created_at && @max_age ? @created_at + @max_age : nil
  end

  # See #expires.
  def expires= t
    case t
    when nil, Time
    else
      t = Time.parse(t)
    end
    @max_age = nil
    @session = t.nil?
    @expires = t
  end

  alias expires_at expires
  alias expires_at= expires=

  attr_reader :max_age

  # See #max_age.
  def max_age= sec
    case sec
    when Integer, nil
    else
      str = String.try_convert(sec) or
        raise TypeError, "#{sec.class} is not an Integer or String"
      /\A-?\d+\z/.match(str) or
        raise ArgumentError, "invalid Max-Age: #{sec.inspect}"
      sec = str.to_i
    end
    @expires = nil
    if @session = sec.nil?
      @max_age = nil
    else
      @max_age = sec
    end
  end

  # Tests if this cookie is expired by now, or by a given time.
  def expired?(time = Time.now)
    if expires = self.expires
      expires <= time
    else
      false
    end
  end

  # Expires this cookie by setting the expires attribute value to a
  # past date.
  def expire!
    self.expires = UNIX_EPOCH
    self
  end

  # The time this cookie was created at.  This value is used as a base
  # date for interpreting the Max-Age attribute value.  See #expires.
  attr_accessor :created_at

  # The time this cookie was last accessed at.
  attr_accessor :accessed_at

  # Tests if it is OK to accept this cookie if it is sent from a given
  # URI/URL, `uri`.
  def acceptable_from_uri?(uri)
    uri = URI(uri)
    return false unless URI::HTTP === uri && uri.host
    host = DomainName.new(uri.host)

    # RFC 6265 5.3
    case
    when host.hostname == @domain
      true
    when @for_domain  # !host-only-flag
      host.cookie_domain?(@domain_name)
    else
      @domain.nil?
    end
  end

  # Tests if it is OK to accept this cookie considering its origin.
  # If either domain or path is missing, raises ArgumentError.  If
  # origin is missing, returns true.
  def acceptable?
    case
    when @domain.nil?
      raise "domain is missing"
    when @path.nil?
      raise "path is missing"
    when @origin.nil?
      true
    else
      acceptable_from_uri?(@origin)
    end
  end

  # Tests if it is OK to send this cookie to a given `uri`.  A
  # RuntimeError is raised if the cookie's domain is unknown.
  def valid_for_uri?(uri)
    if @domain.nil?
      raise "cannot tell if this cookie is valid because the domain is unknown"
    end
    uri = URI(uri)
    # RFC 6265 5.4
    return false if secure? && !(URI::HTTPS === uri)
    acceptable_from_uri?(uri) && HTTP::Cookie.path_match?(@path, uri.path)
  end

  # Returns a string for use in the Cookie header, i.e. `name=value`
  # or `name="value"`.
  def cookie_value
    "#{@name}=#{Scanner.quote(@value)}"
  end
  alias to_s cookie_value

  # Returns a string for use in the Set-Cookie header.  If necessary
  # information like a path or domain (when `for_domain` is set) is
  # missing, RuntimeError is raised.  It is always the best to set an
  # origin before calling this method.
  def set_cookie_value
    string = cookie_value
    if @for_domain
      if @domain
        string << "; Domain=#{@domain}"
      else
        raise "for_domain is specified but domain is unknown"
      end
    end
    if @path
      if !@origin || (@origin + './').path != @path
        string << "; Path=#{@path}"
      end
    else
      raise "path is unknown"
    end
    if @max_age
      string << "; Max-Age=#{@max_age}"
    elsif @expires
      string << "; Expires=#{@expires.httpdate}"
    end
    if @httponly
      string << "; HttpOnly"
    end
    if @secure
      string << "; Secure"
    end
    string
  end

  def inspect
    '#<%s:' % self.class << PERSISTENT_PROPERTIES.map { |key|
      '%s=%s' % [key, instance_variable_get(:"@#{key}").inspect]
    }.join(', ') << ' origin=%s>' % [@origin ? @origin.to_s : 'nil']
  end

  # Compares the cookie with another.  When there are many cookies with
  # the same name for a URL, the value of the smallest must be used.
  def <=> other
    # RFC 6265 5.4
    # Precedence: 1. longer path  2. older creation
    (@name <=> other.name).nonzero? ||
      (other.path.length <=> @path.length).nonzero? ||
      (@created_at <=> other.created_at).nonzero? ||
      @value <=> other.value
  end
  include Comparable

  # YAML serialization helper for Syck.
  def to_yaml_properties
    PERSISTENT_PROPERTIES.map { |name| "@#{name}" }
  end

  # YAML serialization helper for Psych.
  def encode_with(coder)
    PERSISTENT_PROPERTIES.each { |key|
      coder[key.to_s] = instance_variable_get(:"@#{key}")
    }
  end

  # YAML deserialization helper for Syck.
  def init_with(coder)
    yaml_initialize(coder.tag, coder.map)
  end

  # YAML deserialization helper for Psych.
  def yaml_initialize(tag, map)
    expires = nil
    @origin = nil
    map.each { |key, value|
      case key
      when 'expires'
        # avoid clobbering max_age
        expires = value
      when *PERSISTENT_PROPERTIES
        __send__(:"#{key}=", value)
      end
    }
    self.expires = expires if self.max_age.nil?
  end
end
