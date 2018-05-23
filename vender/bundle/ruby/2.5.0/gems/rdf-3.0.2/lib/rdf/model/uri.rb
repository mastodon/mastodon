# coding: utf-8
require 'uri'

module RDF
  ##
  # A Uniform Resource Identifier (URI).
  # Also compatible with International Resource Identifier (IRI)
  #
  # @example Creating a URI reference (1)
  #   uri = RDF::URI.new("http://rubygems.org/gems/rdf")
  #
  # @example Creating a URI reference (2)
  #   uri = RDF::URI.new(scheme: 'http', host: 'rubygems.org', path: '/gems/rdf')
  #     #=> RDF::URI.new("http://rubygems.org/gems/rdf")
  #
  # @example Creating an interned URI reference
  #   uri = RDF::URI.intern("http://rubygems.org/gems/rdf")
  #
  # @example Getting the string representation of a URI
  #   uri.to_s #=> "http://rubygems.org/gems/rdf"
  #
  # http://en.wikipedia.org/wiki/Internationalized_Resource_Identifier
  # @see http://en.wikipedia.org/wiki/Uniform_Resource_Identifier
  # @see http://www.ietf.org/rfc/rfc3986.txt
  # @see http://www.ietf.org/rfc/rfc3987.txt
  # @see http://www.rubydoc.info/gems/addressable
  class URI
    include RDF::Resource

    ##
    # Defines the maximum number of interned URI references that can be held
    # cached in memory at any one time.
    CACHE_SIZE = -1 # unlimited by default
    
    # IRI components
    UCSCHAR = Regexp.compile(<<-EOS.gsub(/\s+/, ''))
      [\\u00A0-\\uD7FF]|[\\uF900-\\uFDCF]|[\\uFDF0-\\uFFEF]|
      [\\u{10000}-\\u{1FFFD}]|[\\u{20000}-\\u{2FFFD}]|[\\u{30000}-\\u{3FFFD}]|
      [\\u{40000}-\\u{4FFFD}]|[\\u{50000}-\\u{5FFFD}]|[\\u{60000}-\\u{6FFFD}]|
      [\\u{70000}-\\u{7FFFD}]|[\\u{80000}-\\u{8FFFD}]|[\\u{90000}-\\u{9FFFD}]|
      [\\u{A0000}-\\u{AFFFD}]|[\\u{B0000}-\\u{BFFFD}]|[\\u{C0000}-\\u{CFFFD}]|
      [\\u{D0000}-\\u{DFFFD}]|[\\u{E1000}-\\u{EFFFD}]
    EOS
    IPRIVATE = Regexp.compile("[\\uE000-\\uF8FF]|[\\u{F0000}-\\u{FFFFD}]|[\\u100000-\\u10FFFD]").freeze
    SCHEME = Regexp.compile("[A-Za-z](?:[A-Za-z0-9+-\.])*").freeze
    PORT = Regexp.compile("[0-9]*").freeze
    IP_literal = Regexp.compile("\\[[0-9A-Fa-f:\\.]*\\]").freeze  # Simplified, no IPvFuture
    PCT_ENCODED = Regexp.compile("%[0-9A-Fa-f][0-9A-Fa-f]").freeze
    GEN_DELIMS = Regexp.compile("[:/\\?\\#\\[\\]@]").freeze
    SUB_DELIMS = Regexp.compile("[!\\$&'\\(\\)\\*\\+,;=]").freeze
    RESERVED = Regexp.compile("(?:#{GEN_DELIMS}|#{SUB_DELIMS})").freeze
    UNRESERVED = Regexp.compile("[A-Za-z0-9\._~-]").freeze

    IUNRESERVED = Regexp.compile("[A-Za-z0-9\._~-]|#{UCSCHAR}").freeze

    IPCHAR = Regexp.compile("(?:#{IUNRESERVED}|#{PCT_ENCODED}|#{SUB_DELIMS}|:|@)").freeze

    IQUERY = Regexp.compile("(?:#{IPCHAR}|#{IPRIVATE}|/|\\?)*").freeze

    IFRAGMENT = Regexp.compile("(?:#{IPCHAR}|/|\\?)*").freeze.freeze

    ISEGMENT = Regexp.compile("(?:#{IPCHAR})*").freeze
    ISEGMENT_NZ = Regexp.compile("(?:#{IPCHAR})+").freeze
    ISEGMENT_NZ_NC = Regexp.compile("(?:(?:#{IUNRESERVED})|(?:#{PCT_ENCODED})|(?:#{SUB_DELIMS})|@)+").freeze

    IPATH_ABEMPTY = Regexp.compile("(?:/#{ISEGMENT})*").freeze
    IPATH_ABSOLUTE = Regexp.compile("/(?:(?:#{ISEGMENT_NZ})(/#{ISEGMENT})*)?").freeze
    IPATH_NOSCHEME = Regexp.compile("(?:#{ISEGMENT_NZ_NC})(?:/#{ISEGMENT})*").freeze
    IPATH_ROOTLESS = Regexp.compile("(?:#{ISEGMENT_NZ})(?:/#{ISEGMENT})*").freeze
    IPATH_EMPTY = Regexp.compile("").freeze

    IREG_NAME   = Regexp.compile("(?:(?:#{IUNRESERVED})|(?:#{PCT_ENCODED})|(?:#{SUB_DELIMS}))*").freeze
    IHOST = Regexp.compile("(?:#{IP_literal})|(?:#{IREG_NAME})").freeze
    IUSERINFO = Regexp.compile("(?:(?:#{IUNRESERVED})|(?:#{PCT_ENCODED})|(?:#{SUB_DELIMS})|:)*").freeze
    IAUTHORITY = Regexp.compile("(?:#{IUSERINFO}@)?#{IHOST}(?::#{PORT})?").freeze
    
    IRELATIVE_PART = Regexp.compile("(?:(?://#{IAUTHORITY}(?:#{IPATH_ABEMPTY}))|(?:#{IPATH_ABSOLUTE})|(?:#{IPATH_NOSCHEME})|(?:#{IPATH_EMPTY}))").freeze
    IRELATIVE_REF = Regexp.compile("^#{IRELATIVE_PART}(?:\\?#{IQUERY})?(?:\\##{IFRAGMENT})?$").freeze

    IHIER_PART = Regexp.compile("(?:(?://#{IAUTHORITY}#{IPATH_ABEMPTY})|(?:#{IPATH_ABSOLUTE})|(?:#{IPATH_ROOTLESS})|(?:#{IPATH_EMPTY}))").freeze
    IRI = Regexp.compile("^#{SCHEME}:(?:#{IHIER_PART})(?:\\?#{IQUERY})?(?:\\##{IFRAGMENT})?$").freeze

    # Split an IRI into it's component parts
    IRI_PARTS = /^(?:([^:\/?#]+):)?(?:\/\/([^\/?#]*))?([^?#]*)(\?[^#]*)?(#.*)?$/.freeze

    # Remove dot expressions regular expressions
    RDS_2A = /^\.?\.\/(.*)$/.freeze
    RDS_2B1 = /^\/\.$/.freeze
    RDS_2B2 = /^(?:\/\.\/)(.*)$/.freeze
    RDS_2C1 = /^\/\.\.$/.freeze
    RDS_2C2 = /^(?:\/\.\.\/)(.*)$/.freeze
    RDS_2D  = /^\.\.?$/.freeze
    RDS_2E = /^(\/?[^\/]*)(\/?.*)?$/.freeze

    # Remove port, if it is standard for the scheme when normalizing
    PORT_MAPPING = {
      "http"     => 80,
      "https"    => 443,
      "ftp"      => 21,
      "tftp"     => 69,
      "sftp"     => 22,
      "ssh"      => 22,
      "svn+ssh"  => 22,
      "telnet"   => 23,
      "nntp"     => 119,
      "gopher"   => 70,
      "wais"     => 210,
      "ldap"     => 389,
      "prospero" => 1525
    }

    # List of schemes known not to be hierarchical
    NON_HIER_SCHEMES = %w(
      about acct bitcoin callto cid data fax geo gtalk h323 iax icon im jabber
      jms magnet mailto maps news pres proxy session sip sips skype sms spotify stun stuns
      tag tel turn turns tv urn javascript
    ).freeze

    ##
    # @return [RDF::Util::Cache]
    # @private
    def self.cache
      require 'rdf/util/cache' unless defined?(::RDF::Util::Cache)
      @cache ||= RDF::Util::Cache.new(CACHE_SIZE)
    end

    ##
    # Returns an interned `RDF::URI` instance based on the given `uri`
    # string.
    #
    # The maximum number of cached interned URI references is given by the
    # `CACHE_SIZE` constant. This value is unlimited by default, in which
    # case an interned URI object will be purged only when the last strong
    # reference to it is garbage collected (i.e., when its finalizer runs).
    #
    # Excepting special memory-limited circumstances, it should always be
    # safe and preferred to construct new URI references using
    # `RDF::URI.intern` instead of `RDF::URI.new`, since if an interned
    # object can't be returned for some reason, this method will fall back
    # to returning a freshly-allocated one.
    #
    # (see #initialize)
    # @return [RDF::URI] an immutable, frozen URI object
    def self.intern(str, *args)
      (cache[(str = str.to_s).to_sym] ||= self.new(str, *args)).freeze
    end

    ##
    # Creates a new `RDF::URI` instance based on the given `uri` string.
    #
    # This is just an alias for {RDF::URI#initialize} for compatibity
    # with `Addressable::URI.parse`. Actual parsing is defered
    # until {#object} is accessed.
    #
    # @param  [String, #to_s] str
    # @return [RDF::URI]
    def self.parse(str)
      self.new(str)
    end

    ##
    # Resolve paths to their simplest form.
    #
    # @todo This process is correct, but overly iterative. It could be better done with a single regexp which handled most of the segment collapses all at once. Parent segments would still require iteration.
    #
    # @param [String] path
    # @return [String] normalized path
    # @see http://tools.ietf.org/html/rfc3986#section-5.2.4
    def self.normalize_path(path)
      output, input = "", path.to_s
      if input.encoding != Encoding::ASCII_8BIT
        input = input.dup if input.frozen?
        input = input.force_encoding(Encoding::ASCII_8BIT)
      end
      until input.empty?
        if input.match(RDS_2A)
          # If the input buffer begins with a prefix of "../" or "./", then remove that prefix from the input buffer; otherwise,
          input = $1
        elsif input.match(RDS_2B1) || input.match(RDS_2B2)
          # if the input buffer begins with a prefix of "/./" or "/.", where "." is a complete path segment, then replace that prefix with "/" in the input buffer; otherwise,
          input = "/#{$1}"
        elsif input.match(RDS_2C1) || input.match(RDS_2C2)
          # if the input buffer begins with a prefix of "/../" or "/..", where ".." is a complete path segment, then replace that prefix with "/" in the input buffer
          input = "/#{$1}"

          #  and remove the last segment and its preceding "/" (if any) from the output buffer; otherwise,
          output.sub!(/\/?[^\/]*$/, '')
        elsif input.match(RDS_2D)
          # if the input buffer consists only of "." or "..", then remove that from the input buffer; otherwise,
          input = ""
        elsif input.match(RDS_2E)
          # move the first path segment in the input buffer to the end of the output buffer, including the initial "/" character (if any) and any subsequent characters up to, but not including, the next "/" character or the end of the input buffer.end
          seg, input = $1, $2
          output << seg
        end
      end

      output.force_encoding(Encoding::UTF_8)
    end

    ##
    # @overload initialize(uri, **options)
    #   @param  [URI, String, #to_s]    uri
    #
    # @overload initialize(**options)
    #   @param  [Hash{Symbol => Object}] options
    #   @option [String, #to_s] :scheme The scheme component.
    #   @option [String, #to_s] :user The user component.
    #   @option [String, #to_s] :password The password component.
    #   @option [String, #to_s] :userinfo
    #     The userinfo component. If this is supplied, the user and password
    #     components must be omitted.
    #   @option [String, #to_s] :host The host component.
    #   @option [String, #to_s] :port The port component.
    #   @option [String, #to_s] :authority
    #     The authority component. If this is supplied, the user, password,
    #     userinfo, host, and port components must be omitted.
    #   @option [String, #to_s] :path The path component.
    #   @option [String, #to_s] :query The query component.
    #   @option [String, #to_s] :fragment The fragment component.
    #
    #   @param [Boolean] validate (false)
    #   @param [Boolean] canonicalize (false)
    def initialize(*args, validate: false, canonicalize: false, **options)
      @value = @object = @hash = nil
      uri = args.first
      if uri
        @value = uri.to_s
        if @value.encoding != Encoding::UTF_8
          @value = @value.dup if @value.frozen?
          @value.force_encoding(Encoding::UTF_8)
          @value.freeze
        end
      else
        %w(
          scheme
          user password userinfo
          host port authority
          path query fragment
        ).map(&:to_sym).each do |meth|
          if options.has_key?(meth)
            self.send("#{meth}=".to_sym, options[meth])
          else
            self.send(meth)
          end
        end
      end

      validate!     if validate
      canonicalize! if canonicalize
    end

    ##
    # Returns `true`.
    #
    # @return [Boolean] `true` or `false`
    # @see    http://en.wikipedia.org/wiki/Uniform_Resource_Identifier
    def uri?
      true
    end

    ##
    # Returns `true` if this URI is a URN.
    #
    # @example
    #   RDF::URI('http://example.org/').urn?                    #=> false
    #
    # @return [Boolean] `true` or `false`
    # @see    http://en.wikipedia.org/wiki/Uniform_Resource_Name
    # @since  0.2.0
    def urn?
      @object ? @object[:scheme] == 'urn' : start_with?('urn:')
    end

    ##
    # Returns `true` if the URI scheme is hierarchical.
    #
    # @example
    #   RDF::URI('http://example.org/').hier?                    #=> true
    #   RDF::URI('urn:isbn:125235111').hier?                     #=> false
    #
    # @return [Boolean] `true` or `false`
    # @see    http://en.wikipedia.org/wiki/URI_scheme
    # @see    NON_HIER_SCHEMES
    # @since  1.0.10
    def hier?
      !NON_HIER_SCHEMES.include?(scheme)
    end

    ##
    # Returns `true` if this URI is a URL.
    #
    # @example
    #   RDF::URI('http://example.org/').url?                    #=> true
    #
    # @return [Boolean] `true` or `false`
    # @see    http://en.wikipedia.org/wiki/Uniform_Resource_Locator
    # @since  0.2.0
    def url?
      !urn?
    end

    ##
    # A URI is absolute when it has a scheme
    # @return [Boolean] `true` or `false`
    def absolute?; !scheme.nil?; end

    ##
    # A URI is relative when it does not have a scheme
    # @return [Boolean] `true` or `false`
    def relative?; !absolute?; end
    
    # Attempt to make this URI relative to the provided `base_uri`. If successful, returns a relative URI, otherwise the original URI
    # @param [#to_s] base_uri
    # @return [RDF::URI]
    def relativize(base_uri)
      if base_uri.to_s.end_with?("/", "#") &&
         self.to_s.start_with?(base_uri.to_s)
        RDF::URI(self.to_s[base_uri.to_s.length..-1])
      else
        self
      end
    end

    ##
    # Returns the string length of this URI.
    #
    # @example
    #   RDF::URI('http://example.org/').length                  #=> 19
    #
    # @return [Integer]
    # @since  0.3.0
    def length
      to_s.length
    end
    alias_method :size, :length

    ##
    # Determine if the URI is a valid according to RFC3987
    #
    # Note that RDF URIs syntactically can contain Unicode escapes, which are unencoded in the internal representation. To validate, %-encode specifically excluded characters from IRIREF
    #
    # @return [Boolean] `true` or `false`
    # @since 0.3.9
    def valid?
      RDF::URI::IRI.match(to_s) || false
    end

    ##
    # Validates this URI, raising an error if it is invalid.
    #
    # @return [RDF::URI] `self`
    # @raise  [ArgumentError] if the URI is invalid
    # @since  0.3.0
    def validate!
      raise ArgumentError, "#{to_base.inspect} is not a valid IRI" if invalid?
      self
    end

    ##
    # Returns a copy of this URI converted into its canonical lexical
    # representation.
    #
    # @return [RDF::URI]
    # @since  0.3.0
    def canonicalize
      self.dup.canonicalize!
    end
    alias_method :normalize, :canonicalize

    ##
    # Converts this URI into its canonical lexical representation.
    #
    # @return [RDF::URI] `self`
    # @since  0.3.0
    def canonicalize!
      @object = {
        scheme: normalized_scheme,
        authority: normalized_authority,
        path: normalized_path.squeeze('/'),
        query: normalized_query,
        fragment: normalized_fragment
      }
      @value = nil
      @hash = nil
      self
    end
    alias_method :normalize!, :canonicalize!

    ##
    # Joins several URIs together.
    #
    # This method conforms to join normalization semantics as per RFC3986,
    # section 5.2.  This method normalizes URIs, removes some duplicate path
    # information, such as double slashes, and other behavior specified in the
    # RFC.
    #
    # Other URI building methods are `#/` and `#+`.
    #
    # For an up-to-date list of edge case behavior, see the shared examples for
    # RDF::URI in the rdf-spec project.
    #
    # @example Joining two URIs
    #     RDF::URI.new('http://example.org/foo/bar').join('/foo')
    #     #=> RDF::URI('http://example.org/foo')
    # @see <http://github.com/ruby-rdf/rdf-spec/blob/master/lib/rdf/spec/uri.rb>
    # @see <http://tools.ietf.org/html/rfc3986#section-5.2>
    # @see RDF::URI#/
    # @see RDF::URI#+
    # @param  [Array<String, RDF::URI, #to_s>] uris absolute or relative URIs.
    # @return [RDF::URI]
    # @see http://tools.ietf.org/html/rfc3986#section-5.2.2
    # @see http://tools.ietf.org/html/rfc3986#section-5.2.3
    def join(*uris)
      joined_parts = object.dup.delete_if {|k, v| [:user, :password, :host, :port].include?(k)}

      uris.each do |uri|
        uri = RDF::URI.new(uri) unless uri.is_a?(RDF::URI)
        next if uri.to_s.empty? # Don't mess with base URI

        case
        when uri.scheme
          joined_parts = uri.object.merge(path: self.class.normalize_path(uri.path))
        when uri.authority
          joined_parts[:authority] = uri.authority
          joined_parts[:path] = self.class.normalize_path(uri.path)
          joined_parts[:query] = uri.query
        when uri.path.to_s.empty?
          joined_parts[:query] = uri.query if uri.query
        when uri.path[0,1] == '/'
          joined_parts[:path] = self.class.normalize_path(uri.path)
          joined_parts[:query] = uri.query
        else
          # Merge path segments from section 5.2.3
          base_path = path.to_s.sub(/\/[^\/]*$/, '/')
          joined_parts[:path] = self.class.normalize_path(base_path + uri.path)
          joined_parts[:query] = uri.query
        end
        joined_parts[:fragment] = uri.fragment
      end

      # Return joined URI
      RDF::URI.new(joined_parts)
    end

    ##
    # 'Smart separator' URI builder
    #
    # This method attempts to use some understanding of the most common use
    # cases for URLs and URNs to create a simple method for building new URIs
    # from fragments.  This means that it will always insert a separator of
    # some sort, will remove duplicate seperators, will always assume that a
    # fragment argument represents a relative and not absolute path, and throws
    # an exception when an absolute URI is received for a fragment argument.
    #
    # This is separate from the semantics for `#join`, which are well-defined by
    # RFC3986 section 5.2 as part of the merging and normalization process;
    # this method does not perform any normalization, removal of spurious
    # paths, or removal of parent directory references `(/../)`.
    #
    # When `fragment` is a path segment containing a colon, best practice is to prepend a `./` and use {#join}, which resolves dot-segments.
    #
    # See also `#+`, which concatenates the string forms of two URIs without
    # any sort of checking or processing.
    #
    # For an up-to-date list of edge case behavior, see the shared examples for
    # RDF::URI in the rdf-spec project.
    #
    # @param [Any] fragment A URI fragment to be appended to this URI
    # @return [RDF::URI]
    # @raise  [ArgumentError] if the URI is invalid
    # @see RDF::URI#+
    # @see RDF::URI#join
    # @see <http://tools.ietf.org/html/rfc3986#section-5.2>
    # @see <http://github.com/ruby-rdf/rdf-spec/blob/master/lib/rdf/spec/uri.rb>
    # @example Building a HTTP URL
    #     RDF::URI.new('http://example.org') / 'jhacker' / 'foaf.ttl'
    #     #=> RDF::URI('http://example.org/jhacker/foaf.ttl')
    # @example Building a HTTP URL (absolute path components)
    #     RDF::URI.new('http://example.org/') / '/jhacker/' / '/foaf.ttl'
    #     #=> RDF::URI('http://example.org/jhacker/foaf.ttl')
    # @example Using an anchored base URI
    #     RDF::URI.new('http://example.org/users#') / 'jhacker'
    #     #=> RDF::URI('http://example.org/users#jhacker')
    # @example Building a URN
    #     RDF::URI.new('urn:isbn') / 125235111
    #     #=> RDF::URI('urn:isbn:125235111')
    def /(fragment)
      frag = fragment.respond_to?(:to_uri) ? fragment.to_uri : RDF::URI(fragment.to_s)
      raise ArgumentError, "Non-absolute URI or string required, got #{frag}" unless frag.relative?
      if urn?
        RDF::URI.intern(to_s.sub(/:+$/,'') + ':' + fragment.to_s.sub(/^:+/,''))
      else # !urn?
        res = self.dup
        if res.fragment
          case fragment.to_s[0,1]
          when '/'
            # Base with a fragment, fragment beginning with '/'. The fragment wins, we use '/'.
            path, frag = fragment.to_s.split('#', 2)
            res.path = "#{res.path}/#{path.sub(/^\/*/,'')}"
            res.fragment = frag
          else
            # Replace fragment
            res.fragment = fragment.to_s.sub(/^#+/,'')
          end
        else
          # Not a fragment. includes '/'. Results from bases ending in '/' are the same as if there were no trailing slash.
          case fragment.to_s[0,1]
          when '#'
            # Base ending with '/', fragment beginning with '#'. The fragment wins, we use '#'.
            res.path = res.path.to_s.sub!(/\/*$/, '')
            # Add fragment
            res.fragment = fragment.to_s.sub(/^#+/,'')
          else
            # Add fragment as path component
            path, frag = fragment.to_s.split('#', 2)
            res.path = res.path.to_s.sub(/\/*$/,'/') + path.sub(/^\/*/,'')
            res.fragment = frag
          end
        end
        RDF::URI.intern(res.to_s)
      end
    end

    ##
    # Simple concatenation operator.  Returns a URI formed from concatenating
    # the string form of two elements.
    #
    # For building URIs from fragments, you may want to use the smart
    # separator, `#/`.  `#join` implements another set of URI building
    # semantics.
    #
    # @example Concatenating a string to a URI
    #     RDF::URI.new('http://example.org/test') + 'test'
    #     #=> RDF::URI('http://example.org/testtest')
    # @example Concatenating two URIs
    #     RDF::URI.new('http://example.org/test') + RDF::URI.new('test')
    #     #=> RDF::URI('http://example.org/testtest')
    # @see RDF::URI#/
    # @see RDF::URI#join
    # @param [Any] other
    # @return [RDF::URI]
    def +(other)
      RDF::URI.intern(self.to_s + other.to_s)
    end

    ##
    # Returns `true` if this URI's scheme is not hierarchical,
    # or its path component is equal to `/`.
    # Protocols not using hierarchical components are always considered
    # to be at the root.
    #
    # @example
    #   RDF::URI('http://example.org/').root?                   #=> true
    #   RDF::URI('http://example.org/path/').root?              #=> false
    #   RDF::URI('urn:isbn').root?                              #=> true
    #
    # @return [Boolean] `true` or `false`
    def root?
      !self.hier?  || self.path == '/' || self.path.to_s.empty?
    end

    ##
    # Returns a copy of this URI with the path component set to `/`.
    #
    # @example
    #   RDF::URI('http://example.org/').root                    #=> RDF::URI('http://example.org/')
    #   RDF::URI('http://example.org/path/').root               #=> RDF::URI('http://example.org/')
    #
    # @return [RDF::URI]
    def root
      if root?
        self
      else
        RDF::URI.new(
          object.merge(path: '/').
          keep_if {|k, v| [:scheme, :authority, :path].include?(k)})
      end
    end

    ##
    # Returns `true` if this URI is hierarchical and it's path component isn't equal to `/`.
    #
    # @example
    #   RDF::URI('http://example.org/').has_parent?             #=> false
    #   RDF::URI('http://example.org/path/').has_parent?        #=> true
    #
    # @return [Boolean] `true` or `false`
    def has_parent?
      !root?
    end

    ##
    # Returns a copy of this URI with the path component ascended to the
    # parent directory, if any.
    #
    # @example
    #   RDF::URI('http://example.org/').parent                  #=> nil
    #   RDF::URI('http://example.org/path/').parent             #=> RDF::URI('http://example.org/')
    #
    # @return [RDF::URI]
    def parent
      case
        when root? then nil
        else
          require 'pathname' unless defined?(Pathname)
          if path = Pathname.new(self.path).parent
            uri = self.dup
            uri.path = path.to_s
            uri.path << '/' unless uri.root?
            uri
          end
      end
    end

    ##
    # Returns a qualified name (QName) for this URI based on available vocabularies, if possible.
    #
    # @example
    #   RDF::URI('http://www.w3.org/2000/01/rdf-schema#').qname       #=> [:rdfs, nil]
    #   RDF::URI('http://www.w3.org/2000/01/rdf-schema#label').qname  #=> [:rdfs, :label]
    #   RDF::RDFS.label.qname                                         #=> [:rdfs, :label]
    #
    # @return [Array(Symbol, Symbol)] or `nil` if no QName found
    def qname
      if self.to_s =~ %r([:/#]([^:/#]*)$)
        local_name = $1
        vocab_uri  = local_name.empty? ? self.to_s : self.to_s[0...-(local_name.length)]
        Vocabulary.each do |vocab|
          if vocab.to_uri == vocab_uri
            prefix = vocab.equal?(RDF) ? :rdf : vocab.__prefix__
            return [prefix, local_name.empty? ? nil : local_name.to_sym]
          end
        end
      else
        Vocabulary.each do |vocab|
          vocab_uri = vocab.to_uri
          if self.start_with?(vocab_uri)
            prefix = vocab.equal?(RDF) ? :rdf : vocab.__prefix__
            local_name = self.to_s[vocab_uri.length..-1]
            return [prefix, local_name.empty? ? nil : local_name.to_sym]
          end
        end
      end
      return nil # no QName found
    end

    ##
    # Returns a string version of the QName or the full IRI
    #
    # @return [String] or `nil`
    def pname
      (q = self.qname) ? q.join(":") : to_s
    end

    ##
    # Returns a duplicate copy of `self`.
    #
    # @return [RDF::URI]
    def dup
      self.class.new((@value || @object).dup)
    end

    ##
    # @private
    def freeze
      unless frozen?
        # Create derived components
        authority; userinfo; user; password; host; port
        @value  = value.freeze
        @object = object.freeze
        @hash = hash.freeze
        super
      end
      self
    end

    ##
    # Returns `true` if this URI ends with the given `string`.
    #
    # @example
    #   RDF::URI('http://example.org/').end_with?('/')          #=> true
    #   RDF::URI('http://example.org/').end_with?('#')          #=> false
    #
    # @param  [String, #to_s] string
    # @return [Boolean] `true` or `false`
    # @see    String#end_with?
    # @since  0.3.0
    def end_with?(string)
      to_s.end_with?(string.to_s)
    end
    alias_method :ends_with?, :end_with?

    ##
    # Checks whether this URI the same term as `other`.
    #
    # @example
    #   RDF::URI('http://t.co/').eql?(RDF::URI('http://t.co/'))    #=> true
    #   RDF::URI('http://t.co/').eql?('http://t.co/')              #=> false
    #   RDF::URI('http://www.w3.org/2000/01/rdf-schema#').eql?(RDF::RDFS) #=> false
    #
    # @param  [RDF::URI] other
    # @return [Boolean] `true` or `false`
    def eql?(other)
      other.is_a?(URI) && self.hash == other.hash && self == other
    end

    ##
    # Checks whether this URI is equal to `other` (type checking).
    #
    # Per SPARQL data-r2/expr-equal/eq-2-2, numeric can't be compared with other types
    #
    # @example
    #   RDF::URI('http://t.co/') == RDF::URI('http://t.co/')    #=> true
    #   RDF::URI('http://t.co/') == 'http://t.co/'              #=> true
    #   RDF::URI('http://www.w3.org/2000/01/rdf-schema#') == RDF::RDFS        #=> true
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
    def ==(other)
      case other
      when Literal
        # If other is a Literal, reverse test to consolodate complex type checking logic
        other == self
      when String then to_s == other
      when URI then hash == other.hash && to_s == other.to_s
      else other.respond_to?(:to_uri) && to_s == other.to_uri.to_s
      end
    end

    ##
    # Checks for case equality to the given `other` object.
    #
    # @example
    #   RDF::URI('http://example.org/') === /example/           #=> true
    #   RDF::URI('http://example.org/') === /foobar/            #=> false
    #   RDF::URI('http://t.co/') === RDF::URI('http://t.co/')   #=> true
    #   RDF::URI('http://t.co/') === 'http://t.co/'             #=> true
    #   RDF::URI('http://www.w3.org/2000/01/rdf-schema#') === RDF::RDFS       #=> true
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def ===(other)
      case other
        when Regexp then other === to_s
        else self == other
      end
    end

    ##
    # Performs a pattern match using the given regular expression.
    #
    # @example
    #   RDF::URI('http://example.org/') =~ /example/            #=> 7
    #   RDF::URI('http://example.org/') =~ /foobar/             #=> nil
    #
    # @param  [Regexp] pattern
    # @return [Integer] the position the match starts
    # @see    String#=~
    # @since  0.3.0
    def =~(pattern)
      case pattern
        when Regexp then to_s =~ pattern
        else super # `Object#=~` returns `false`
      end
    end

    ##
    # Returns `self`.
    #
    # @return [RDF::URI] `self`
    def to_uri
      self
    end

    ##
    # Returns the string representation of this URI.
    #
    # @example
    #   RDF::URI('http://example.org/').to_str                  #=> 'http://example.org/'
    #
    # @return [String]
    def to_str; value; end
    alias_method :to_s, :to_str

    ##
    # Returns a <code>String</code> representation of the URI object's state.
    #
    # @return [String] The URI object's state, as a <code>String</code>.
    def inspect
      sprintf("#<%s:%#0x URI:%s>", URI.to_s, self.object_id, self.to_s)
    end

    ##
    # lexical representation of URI, either absolute or relative
    # @return [String] 
    def value
      return @value if @value
      @value = [
        ("#{scheme}:" if absolute?),
        ("//#{authority}" if authority),
        path,
        ("?#{query}" if query),
        ("##{fragment}" if fragment)
      ].compact.join("").freeze
    end

    ##
    # Returns a hash code for this URI.
    #
    # @return [Integer]
    def hash
      @hash || @hash = (value.hash * -1)
    end

    ##
    # Returns object representation of this URI, broken into components
    #
    # @return [Hash{Symbol => String}]
    def object
      @object || @object = parse(@value)
    end
    alias_method :to_h, :object

    ##{
    # Parse a URI into it's components
    #
    # @param [String, to_s] value
    # @return [Object{Symbol => String}]
    def parse(value)
      value = value.to_s.dup.force_encoding(Encoding::ASCII_8BIT)
      parts = {}
      if matchdata = IRI_PARTS.match(value)
        scheme, authority, path, query, fragment = matchdata[1..-1]
        userinfo, hostport = authority.to_s.split('@', 2)
        hostport, userinfo = userinfo, nil unless hostport
        user, password = userinfo.to_s.split(':', 2)
        host, port = hostport.to_s.split(':', 2)

        parts[:scheme] = (scheme.force_encoding(Encoding::UTF_8) if scheme)
        parts[:authority] = (authority.force_encoding(Encoding::UTF_8) if authority)
        parts[:userinfo] = (userinfo.force_encoding(Encoding::UTF_8) if userinfo)
        parts[:user] = (user.force_encoding(Encoding::UTF_8) if user)
        parts[:password] = (password.force_encoding(Encoding::UTF_8) if password)
        parts[:host] = (host.force_encoding(Encoding::UTF_8) if host)
        parts[:port] = (::URI.decode(port).to_i if port)
        parts[:path] = (path.to_s.force_encoding(Encoding::UTF_8) unless path.empty?)
        parts[:query] = (query[1..-1].force_encoding(Encoding::UTF_8) if query)
        parts[:fragment] = (fragment[1..-1].force_encoding(Encoding::UTF_8) if fragment)
      end
      
      parts
    end

    ##
    # @return [String]
    def scheme
      object.fetch(:scheme) do
        nil
      end
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def scheme=(value)
      object[:scheme] = (value.to_s.force_encoding(Encoding::UTF_8) if value)
      @value = nil
      self
    end

    ##
    # Return normalized version of scheme, if any
    # @return [String]
    def normalized_scheme
      normalize_segment(scheme.strip, SCHEME, true) if scheme
    end

    ##
    # @return [String]
    def user
      object.fetch(:user) do
        @object[:user] = (userinfo.split(':', 2)[0] if userinfo)
      end
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def user=(value)
      object[:user] = (value.to_s.force_encoding(Encoding::UTF_8) if value)
      @object[:userinfo] = format_userinfo("")
      @object[:authority] = format_authority
      @value = nil
      self
    end
    
    ##
    # Normalized version of user
    # @return [String]
    def normalized_user
      ::URI.encode(::URI.decode(user), /[^#{IUNRESERVED}|#{SUB_DELIMS}]/) if user
    end

    ##
    # @return [String]
    def password
      object.fetch(:password) do
        @object[:password] = (userinfo.split(':', 2)[1] if userinfo)
      end
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def password=(value)
      object[:password] = (value.to_s.force_encoding(Encoding::UTF_8) if value)
      @object[:userinfo] = format_userinfo("")
      @object[:authority] = format_authority
      @value = nil
      self
    end
    
    ##
    # Normalized version of password
    # @return [String]
    def normalized_password
      ::URI.encode(::URI.decode(password), /[^#{IUNRESERVED}|#{SUB_DELIMS}]/) if password
    end

    HOST_FROM_AUTHORITY_RE = /(?:[^@]+@)?([^:]+)(?::.*)?$/.freeze

    ##
    # @return [String]
    def host
      object.fetch(:host) do
        @object[:host] = ($1 if HOST_FROM_AUTHORITY_RE.match(@object[:authority]))
      end
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def host=(value)
      object[:host] = (value.to_s.force_encoding(Encoding::UTF_8) if value)
      @object[:authority] = format_authority
      @value = nil
      self
    end
    
    ##
    # Normalized version of host
    # @return [String]
    def normalized_host
      # Remove trailing '.' characters
      normalize_segment(host, IHOST, true).chomp('.') if host
    end

    PORT_FROM_AUTHORITY_RE = /:(\d+)$/.freeze

    ##
    # @return [String]
    def port
      object.fetch(:port) do
        @object[:port] = ($1 if PORT_FROM_AUTHORITY_RE.match(@object[:authority]))
      end
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def port=(value)
      object[:port] = (value.to_s.to_i if value)
      @object[:authority] = format_authority
      @value = nil
      self
    end
    
    ##
    # Normalized version of port
    # @return [String]
    def normalized_port
      if port
        np = normalize_segment(port.to_s, PORT)
        if PORT_MAPPING[normalized_scheme] == np.to_i
          nil
        else
          np.to_i
        end
      end
    end

    ##
    # @return [String]
    def path
      object.fetch(:path) do
        nil
      end
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def path=(value)
      if value
        # Always lead with a slash
        value = "/#{value}" if host && value.to_s =~ /^[^\/]/
        object[:path] = value.to_s.force_encoding(Encoding::UTF_8)
      else
        object[:path] = nil
      end
      @value = nil
      self
    end
    
    ##
    # Normalized version of path
    # @return [String]
    def normalized_path
      segments = path.to_s.split('/', -1) # preserve null segments

      norm_segs = case
      when authority
        # ipath-abempty
        segments.map {|s| normalize_segment(s, ISEGMENT)}
      when segments[0].nil?
        # ipath-absolute
        res = [nil]
        res << normalize_segment(segments[1], ISEGMENT_NZ) if segments.length > 1
        res += segments[2..-1].map {|s| normalize_segment(s, ISEGMENT)} if segments.length > 2
        res
      when segments[0].to_s.index(':')
        # ipath-noscheme
        res = []
        res << normalize_segment(segments[0], ISEGMENT_NZ_NC)
        res += segments[1..-1].map {|s| normalize_segment(s, ISEGMENT)} if segments.length > 1
        res
      when segments[0]
        # ipath-rootless
        # ipath-noscheme
        res = []
        res << normalize_segment(segments[0], ISEGMENT_NZ)
        res += segments[1..-1].map {|s| normalize_segment(s, ISEGMENT)} if segments.length > 1
        res
      else
        # Should be empty
        segments
      end

      res = self.class.normalize_path(norm_segs.join("/"))
      # Special rules for specific protocols having empty paths
      normalize_segment(res.empty? ? (%w(http https ftp tftp).include?(normalized_scheme) ? '/' : "") : res, IHIER_PART)
    end

    ##
    # @return [String]
    def query
      object.fetch(:query) do
        nil
      end
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def query=(value)
      object[:query] = (value.to_s.force_encoding(Encoding::UTF_8) if value)
      @value = nil
      self
    end

    ##
    # Normalized version of query
    # @return [String]
    def normalized_query
      normalize_segment(query, IQUERY) if query
    end

    ##
    # @return [String]
    def fragment
      object.fetch(:fragment) do
        nil
      end
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def fragment=(value)
      object[:fragment] = (value.to_s.force_encoding(Encoding::UTF_8) if value)
      @value = nil
      self
    end

    ##
    # Normalized version of fragment
    # @return [String]
    def normalized_fragment
      normalize_segment(fragment, IFRAGMENT) if fragment
    end

    ##
    # Authority is a combination of user, password, host and port
    def authority
      object.fetch(:authority) {
        @object[:authority] = (format_authority if @object[:host])
      }
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def authority=(value)
      object.delete_if {|k, v| [:user, :password, :host, :port, :userinfo].include?(k)}
      object[:authority] = (value.to_s.force_encoding(Encoding::UTF_8) if value)
      user; password; userinfo; host; port
      @value = nil
      self
    end

    ##
    # Return normalized version of authority, if any
    # @return [String]
    def normalized_authority
      if authority
        (userinfo ? normalized_userinfo.to_s + "@" : "") +
        normalized_host.to_s +
        (normalized_port ? ":" + normalized_port.to_s : "")
      end
    end

    ##
    # Userinfo is a combination of user and password
    def userinfo
      object.fetch(:userinfo) {
        @object[:userinfo] = (format_userinfo("") if @object[:user])
      }
    end

    ##
    # @param [String, #to_s] value
    # @return [RDF::URI] self
    def userinfo=(value)
      object.delete_if {|k, v| [:user, :password, :authority].include?(k)}
      object[:userinfo] = (value.to_s.force_encoding(Encoding::UTF_8) if value)
      user; password; authority
      @value = nil
      self
    end
    
    ##
    # Normalized version of userinfo
    # @return [String]
    def normalized_userinfo
      normalized_user + (password ? ":#{normalized_password}" : "") if userinfo
    end

    ##
    # Converts the query component to a Hash value.
    #
    # @example
    #   RDF::URI.new("?one=1&two=2&three=3").query_values
    #   #=> {"one" => "1", "two" => "2", "three" => "3"}
    #   RDF::URI.new("?one=two&one=three").query_values(Array)
    #   #=> [["one", "two"], ["one", "three"]]
    #   RDF::URI.new("?one=two&one=three").query_values(Hash)
    #   #=> {"one" => ["two", "three"]}
    #
    # @param [Class] return_type (Hash)
    #   The return type desired. Value must be either #   `Hash` or `Array`.
    # @return [Hash, Array] The query string parsed as a Hash or Array object.
    def query_values(return_type=Hash)
      raise ArgumentError, "Invalid return type. Must be Hash or Array." unless [Hash, Array].include?(return_type)
      return nil if query.nil?
      query.to_s.split('&').
        inject(return_type == Hash ? {} : []) do |memo,kv|
          k,v = kv.to_s.split('=', 2)
          next if k.to_s.empty?
          k = ::URI.decode(k)
          v = ::URI.decode(v) if v
          if return_type == Hash
            case memo[k]
            when nil then memo[k] = v
            when Array then memo[k] << v
            else memo[k] = [memo[k], v]
            end
          else
            memo << [k, v].compact
          end
          memo
        end
    end

    ##
    # Sets the query component for this URI from a Hash object.
    # An empty Hash or Array will result in an empty query string.
    #
    # @example Hash with single and array values
    #   uri.query_values = {a: "a", b: ["c", "d", "e"]}
    #   uri.query
    #   # => "a=a&b=c&b=d&b=e"
    #
    # @example Array with Array values including repeated variables
    #   uri.query_values = [['a', 'a'], ['b', 'c'], ['b', 'd'], ['b', 'e']]
    #   uri.query
    #   # => "a=a&b=c&b=d&b=e"
    #
    # @example Array with Array values including multiple elements
    #   uri.query_values = [['a', 'a'], ['b', ['c', 'd', 'e']]]
    #   uri.query
    #   # => "a=a&b=c&b=d&b=e"
    #
    # @example Array with Array values having only one entry
    #   uri.query_values = [['flag'], ['key', 'value']]
    #   uri.query
    #   # => "flag&key=value"
    #
    # @param [Hash, #to_hash, Array] value The new query values.
    def query_values=(value)
      if value.nil?
        self.query = nil
        return
      end

      value = value.to_hash if value.respond_to?(:to_hash)
      self.query = case value
      when Array, Hash
        value.map do |(k,v)|
          k = normalize_segment(k.to_s, UNRESERVED)
          if v.nil?
            k
          else
            Array(v).map do |vv|
              if vv === TrueClass
                k
              else
                "#{k}=#{normalize_segment(vv.to_s, UNRESERVED)}"
              end
            end.join("&")
          end
        end
      else
        raise TypeError,
          "Can't convert #{value.class} into Hash."
      end.join("&")
    end

    ##
    # The HTTP request URI for this URI.  This is the path and the
    # query string.
    #
    # @return [String] The request URI required for an HTTP request.
    def request_uri
      return nil if absolute? && scheme !~ /^https?$/
      res = path.to_s.empty? ? "/" : path
      res += "?#{self.query}" if self.query
      return res
    end

  private

    ##
    # Normalize a segment using a character range
    #
    # @param [String] value
    # @param [Regexp] expr
    # @param [Boolean] downcase
    # @return [String]
    def normalize_segment(value, expr, downcase = false)
      if value
        value = value.dup if value.frozen?
        value = value.force_encoding(Encoding::UTF_8)
        decoded = ::URI.decode(value)
        decoded.downcase! if downcase
        ::URI.encode(decoded, /[^(?:#{expr})]/)
      end
    end

    def format_userinfo(append = "")
      if @object[:user]
        @object[:user] + (@object[:password] ? ":#{@object[:password]}" : "") + append
      else
        ""
      end
    end

    def format_authority
      if @object[:host]
        format_userinfo("@") + @object[:host] + (object[:port] ? ":#{object[:port]}" : "")
      else
        ""
      end
    end
  end

  # RDF::IRI is a synonym for RDF::URI
  IRI = URI
end # RDF
