module CssParser
  # Exception class used for any errors encountered while downloading remote files.
  class RemoteFileError < IOError; end

  # Exception class used if a request is made to load a CSS file more than once.
  class CircularReferenceError < StandardError; end

  # == Parser class
  #
  # All CSS is converted to UTF-8.
  #
  # When calling Parser#new there are some configuaration options:
  # [<tt>absolute_paths</tt>] Convert relative paths to absolute paths (<tt>href</tt>, <tt>src</tt> and <tt>url('')</tt>. Boolean, default is <tt>false</tt>.
  # [<tt>import</tt>] Follow <tt>@import</tt> rules. Boolean, default is <tt>true</tt>.
  # [<tt>io_exceptions</tt>] Throw an exception if a link can not be found. Boolean, default is <tt>true</tt>.
  class Parser
    USER_AGENT   = "Ruby CSS Parser/#{CssParser::VERSION} (https://github.com/premailer/css_parser)"

    STRIP_CSS_COMMENTS_RX = /\/\*.*?\*\//m
    STRIP_HTML_COMMENTS_RX = /\<\!\-\-|\-\-\>/m

    # Initial parsing
    RE_AT_IMPORT_RULE = /\@import\s*(?:url\s*)?(?:\()?(?:\s*)["']?([^'"\s\)]*)["']?\)?([\w\s\,^\]\(\)]*)\)?[;\n]?/

    MAX_REDIRECTS = 3

    # Array of CSS files that have been loaded.
    attr_reader   :loaded_uris

    #--
    # Class variable? see http://www.oreillynet.com/ruby/blog/2007/01/nubygems_dont_use_class_variab_1.html
    #++
    @folded_declaration_cache = {}
    class << self; attr_reader :folded_declaration_cache; end

    def initialize(options = {})
      @options = {:absolute_paths => false,
                  :import => true,
                  :io_exceptions => true,
                  :capture_offsets => false}.merge(options)

      # array of RuleSets
      @rules = []

      @redirect_count = nil

      @loaded_uris = []

      # unprocessed blocks of CSS
      @blocks = []
      reset!
    end

    # Get declarations by selector.
    #
    # +media_types+ are optional, and can be a symbol or an array of symbols.
    # The default value is <tt>:all</tt>.
    #
    # ==== Examples
    #  find_by_selector('#content')
    #  => 'font-size: 13px; line-height: 1.2;'
    #
    #  find_by_selector('#content', [:screen, :handheld])
    #  => 'font-size: 13px; line-height: 1.2;'
    #
    #  find_by_selector('#content', :print)
    #  => 'font-size: 11pt; line-height: 1.2;'
    #
    # Returns an array of declarations.
    def find_by_selector(selector, media_types = :all)
      out = []
      each_selector(media_types) do |sel, dec, spec|
        out << dec if sel.strip == selector.strip
      end
      out
    end
    alias_method :[], :find_by_selector

    # Finds the rule sets that match the given selectors
    def find_rule_sets(selectors, media_types = :all)
      rule_sets = []

      selectors.each do |selector|
        selector.gsub!(/\s+/, ' ')
        selector.strip!
        each_rule_set(media_types) do |rule_set, media_type|
          if !rule_sets.member?(rule_set) && rule_set.selectors.member?(selector)
            rule_sets << rule_set
          end
        end
      end

      rule_sets
    end

    # Add a raw block of CSS.
    #
    # In order to follow +@import+ rules you must supply either a
    # +:base_dir+ or +:base_uri+ option.
    #
    # Use the +:media_types+ option to set the media type(s) for this block.  Takes an array of symbols.
    #
    # Use the +:only_media_types+ option to selectively follow +@import+ rules.  Takes an array of symbols.
    #
    # ==== Example
    #   css = <<-EOT
    #     body { font-size: 10pt }
    #     p { margin: 0px; }
    #     @media screen, print {
    #       body { line-height: 1.2 }
    #     }
    #   EOT
    #
    #   parser = CssParser::Parser.new
    #   parser.add_block!(css)
    def add_block!(block, options = {})
      options = {:base_uri => nil, :base_dir => nil, :charset => nil, :media_types => :all, :only_media_types => :all}.merge(options)
      options[:media_types] = [options[:media_types]].flatten.collect { |mt| CssParser.sanitize_media_query(mt)}
      options[:only_media_types] = [options[:only_media_types]].flatten.collect { |mt| CssParser.sanitize_media_query(mt)}

      block = cleanup_block(block, options)

      if options[:base_uri] and @options[:absolute_paths]
        block = CssParser.convert_uris(block, options[:base_uri])
      end

      # Load @imported CSS
      if @options[:import]
        block.scan(RE_AT_IMPORT_RULE).each do |import_rule|
          media_types = []
          if media_string = import_rule[-1]
            media_string.split(/[,]/).each do |t|
              media_types << CssParser.sanitize_media_query(t) unless t.empty?
            end
          else
            media_types = [:all]
          end

          next unless options[:only_media_types].include?(:all) or media_types.length < 1 or (media_types & options[:only_media_types]).length > 0

          import_path = import_rule[0].to_s.gsub(/['"]*/, '').strip

          import_options = { :media_types => media_types }
          import_options[:capture_offsets] = true if options[:capture_offsets]

          if options[:base_uri]
            import_uri = Addressable::URI.parse(options[:base_uri].to_s) + Addressable::URI.parse(import_path)
            import_options[:base_uri] = options[:base_uri]
            load_uri!(import_uri, import_options)
          elsif options[:base_dir]
            import_options[:base_dir] = options[:base_dir]
            load_file!(import_path, import_options)
          end
        end
      end

      # Remove @import declarations
      block = ignore_pattern(block, RE_AT_IMPORT_RULE, options)

      parse_block_into_rule_sets!(block, options)
    end

    # Add a CSS rule by setting the +selectors+, +declarations+ and +media_types+.
    #
    # +media_types+ can be a symbol or an array of symbols.
    def add_rule!(selectors, declarations, media_types = :all)
      rule_set = RuleSet.new(selectors, declarations)
      add_rule_set!(rule_set, media_types)
    end

    # Add a CSS rule by setting the +selectors+, +declarations+, +filename+, +offset+ and +media_types+.
    #
    # +filename+ can be a string or uri pointing to the file or url location.
    # +offset+ should be Range object representing the start and end byte locations where the rule was found in the file.
    # +media_types+ can be a symbol or an array of symbols.
    def add_rule_with_offsets!(selectors, declarations, filename, offset, media_types = :all)
      rule_set = OffsetAwareRuleSet.new(filename, offset, selectors, declarations)
      add_rule_set!(rule_set, media_types)
    end

    # Add a CssParser RuleSet object.
    #
    # +media_types+ can be a symbol or an array of symbols.
    def add_rule_set!(ruleset, media_types = :all)
      raise ArgumentError unless ruleset.kind_of?(CssParser::RuleSet)

      media_types = [media_types].flatten.collect { |mt| CssParser.sanitize_media_query(mt)}

      @rules << {:media_types => media_types, :rules => ruleset}
    end

    # Remove a CssParser RuleSet object.
    #
    # +media_types+ can be a symbol or an array of symbols.
    def remove_rule_set!(ruleset, media_types = :all)
      raise ArgumentError unless ruleset.kind_of?(CssParser::RuleSet)

      media_types = [media_types].flatten.collect { |mt| CssParser.sanitize_media_query(mt)}

      @rules.reject! do |rule|
        rule[:media_types] == media_types && rule[:rules].to_s == ruleset.to_s
      end
    end

    # Iterate through RuleSet objects.
    #
    # +media_types+ can be a symbol or an array of symbols.
    def each_rule_set(media_types = :all) # :yields: rule_set, media_types
      media_types = [:all] if media_types.nil?
      media_types = [media_types].flatten.collect { |mt| CssParser.sanitize_media_query(mt)}

      @rules.each do |block|
        if media_types.include?(:all) or block[:media_types].any? { |mt| media_types.include?(mt) }
          yield(block[:rules], block[:media_types])
        end
      end
    end

    # Output all CSS rules as a Hash
    def to_h(which_media = :all)
      out = {}
      styles_by_media_types = {}
      each_selector(which_media) do |selectors, declarations, specificity, media_types|
        media_types.each do |media_type|
          styles_by_media_types[media_type] ||= []
          styles_by_media_types[media_type] << [selectors, declarations]
        end
      end

      styles_by_media_types.each_pair do |media_type, media_styles|
        ms = {}
        media_styles.each do |media_style|
          ms = css_node_to_h(ms, media_style[0], media_style[1])
        end
        out[media_type.to_s] = ms
      end
      out
    end

    # Iterate through CSS selectors.
    #
    # +media_types+ can be a symbol or an array of symbols.
    # See RuleSet#each_selector for +options+.
    def each_selector(all_media_types = :all, options = {}) # :yields: selectors, declarations, specificity, media_types
      each_rule_set(all_media_types) do |rule_set, media_types|
        rule_set.each_selector(options) do |selectors, declarations, specificity|
          yield selectors, declarations, specificity, media_types
        end
      end
    end

    # Output all CSS rules as a single stylesheet.
    def to_s(which_media = :all)
      out = ''
      styles_by_media_types = {}
      each_selector(which_media) do |selectors, declarations, specificity, media_types|
        media_types.each do |media_type|
          styles_by_media_types[media_type] ||= []
          styles_by_media_types[media_type] << [selectors, declarations]
        end
      end

      styles_by_media_types.each_pair do |media_type, media_styles|
        media_block = (media_type != :all)
        out += "@media #{media_type} {\n" if media_block

        media_styles.each do |media_style|
          if media_block
            out += "  #{media_style[0]} {\n    #{media_style[1]}\n  }\n"
          else
            out += "#{media_style[0]} {\n#{media_style[1]}\n}\n"
          end
        end

        out += "}\n" if media_block
      end

      out
    end

    # A hash of { :media_query => rule_sets }
    def rules_by_media_query
      rules_by_media = {}
      @rules.each do |block|
        block[:media_types].each do |mt|
          unless rules_by_media.has_key?(mt)
            rules_by_media[mt] = []
          end
          rules_by_media[mt] << block[:rules]
        end
      end

      rules_by_media
    end

    # Merge declarations with the same selector.
    def compact! # :nodoc:
      compacted = []

      compacted
    end

    def parse_block_into_rule_sets!(block, options = {}) # :nodoc:
      current_media_queries = [:all]
      if options[:media_types]
        current_media_queries = options[:media_types].flatten.collect { |mt| CssParser.sanitize_media_query(mt)}
      end

      in_declarations = 0
      block_depth = 0

      in_charset = false # @charset is ignored for now
      in_string = false
      in_at_media_rule = false
      in_media_block = false

      current_selectors = ''
      current_media_query = ''
      current_declarations = ''

      # once we are in a rule, we will use this to store where we started if we are capturing offsets
      rule_start = nil
      offset = nil

      block.scan(/(([\\]{2,})|([\\]?[{}\s"])|(.[^\s"{}\\]*))/) do |matches|
        token = matches[0]

        # save the regex offset so that we know where in the file we are
        offset = Regexp.last_match.offset(0) if options[:capture_offsets]

        if token =~ /\A"/ # found un-escaped double quote
          in_string = !in_string
        end

        if in_declarations > 0
          # too deep, malformed declaration block
          if in_declarations > 1
            in_declarations -= 1 if token =~ /\}/
            next
          end

          if token =~ /\{/ and not in_string
            in_declarations += 1
            next
          end

          current_declarations += token

          if token =~ /\}/ and not in_string
            current_declarations.gsub!(/\}[\s]*$/, '')

            in_declarations -= 1

            unless current_declarations.strip.empty?
              if options[:capture_offsets]
                add_rule_with_offsets!(current_selectors, current_declarations, options[:filename], (rule_start..offset.last), current_media_queries)
              else
                add_rule!(current_selectors, current_declarations, current_media_queries)
              end
            end

            current_selectors = ''
            current_declarations = ''

            # restart our search for selectors and declarations
            rule_start = nil if options[:capture_offsets]
          end
        elsif token =~ /@media/i
          # found '@media', reset current media_types
          in_at_media_rule = true
          current_media_queries = []
        elsif in_at_media_rule
          if token =~ /\{/
            block_depth = block_depth + 1
            in_at_media_rule = false
            in_media_block = true
            current_media_queries << CssParser.sanitize_media_query(current_media_query)
            current_media_query = ''
          elsif token =~ /[,]/
            # new media query begins
            token.gsub!(/[,]/, ' ')
            current_media_query += token.strip + ' '
            current_media_queries << CssParser.sanitize_media_query(current_media_query)
            current_media_query = ''
          else
            current_media_query += token.strip + ' '
          end
        elsif in_charset or token =~ /@charset/i
          # iterate until we are out of the charset declaration
          in_charset = (token =~ /;/ ? false : true)
        else
          if token =~ /\}/ and not in_string
            block_depth = block_depth - 1

            # reset the current media query scope
            if in_media_block
              current_media_queries = [:all]
              in_media_block = false
            end
          else
            if token =~ /\{/ and not in_string
              current_selectors.strip!
              in_declarations += 1
            else
              # if we are in a selector, add the token to the current selectors
              current_selectors += token

              # mark this as the beginning of the selector unless we have already marked it
              rule_start = offset.first if options[:capture_offsets] && rule_start.nil? && token =~ /^[^\s]+$/
            end
          end
        end
      end

      # check for unclosed braces
      if in_declarations > 0
        if options[:capture_offsets]
          add_rule_with_offsets!(current_selectors, current_declarations, options[:filename], (rule_start..offset.last), current_media_queries)
        else
          add_rule!(current_selectors, current_declarations, current_media_queries)
        end
      end
    end

    # Load a remote CSS file.
    #
    # You can also pass in file://test.css
    #
    # See add_block! for options.
    #
    # Deprecated: originally accepted three params: `uri`, `base_uri` and `media_types`
    def load_uri!(uri, options = {}, deprecated = nil)
      uri = Addressable::URI.parse(uri) unless uri.respond_to? :scheme

      opts = {:base_uri => nil, :media_types => :all}

      if options.is_a? Hash
        opts.merge!(options)
      else
        opts[:base_uri] = options if options.is_a? String
        opts[:media_types] = deprecated if deprecated
      end

      if uri.scheme == 'file' or uri.scheme.nil?
        uri.path = File.expand_path(uri.path)
        uri.scheme = 'file'
      end

      opts[:base_uri] = uri if opts[:base_uri].nil?

      # pass on the uri if we are capturing file offsets
      opts[:filename] = uri.to_s if opts[:capture_offsets]

      src, = read_remote_file(uri) # skip charset
      if src
        add_block!(src, opts)
      end
    end

    # Load a local CSS file.
    def load_file!(file_name, options = {}, deprecated = nil)
      opts = {:base_dir => nil, :media_types => :all}

      if options.is_a? Hash
        opts.merge!(options)
      else
        opts[:base_dir] = options if options.is_a? String
        opts[:media_types] = deprecated if deprecated
      end

      file_name = File.expand_path(file_name, opts[:base_dir])
      return unless File.readable?(file_name)
      return unless circular_reference_check(file_name)

      src = IO.read(file_name)

      opts[:filename] = file_name if opts[:capture_offsets]
      opts[:base_dir] = File.dirname(file_name)

      add_block!(src, opts)
    end

    # Load a local CSS string.
    def load_string!(src, options = {}, deprecated = nil)
      opts = {:base_dir => nil, :media_types => :all}

      if options.is_a? Hash
        opts.merge!(options)
      else
        opts[:base_dir] = options if options.is_a? String
        opts[:media_types] = deprecated if deprecated
      end

      add_block!(src, opts)
    end



  protected
    # Check that a path hasn't been loaded already
    #
    # Raises a CircularReferenceError exception if io_exceptions are on,
    # otherwise returns true/false.
    def circular_reference_check(path)
      path = path.to_s
      if @loaded_uris.include?(path)
        raise CircularReferenceError, "can't load #{path} more than once" if @options[:io_exceptions]
        return false
      else
        @loaded_uris << path
        return true
      end
    end

    # Remove a pattern from a given string
    #
    # Returns a string.
    def ignore_pattern(css, regex, options)
      # if we are capturing file offsets, replace the characters with spaces to retail the original positions
      return css.gsub(regex) { |m| ' ' * m.length } if options[:capture_offsets]

      # otherwise just strip it out
      css.gsub(regex, '')
    end

    # Strip comments and clean up blank lines from a block of CSS.
    #
    # Returns a string.
    def cleanup_block(block, options = {}) # :nodoc:
      # Strip CSS comments
      utf8_block = block.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ' ')
      utf8_block = ignore_pattern(utf8_block, STRIP_CSS_COMMENTS_RX, options)

      # Strip HTML comments - they shouldn't really be in here but
      # some people are just crazy...
      utf8_block = ignore_pattern(utf8_block, STRIP_HTML_COMMENTS_RX, options)

      # Strip lines containing just whitespace
      utf8_block.gsub!(/^\s+$/, "") unless options[:capture_offsets]

      utf8_block
    end

    # Download a file into a string.
    #
    # Returns the file's data and character set in an array.
    #--
    # TODO: add option to fail silently or throw and exception on a 404
    #++
    def read_remote_file(uri) # :nodoc:
      if @redirect_count.nil?
        @redirect_count = 0
      else
        @redirect_count += 1
      end

      unless circular_reference_check(uri.to_s)
        @redirect_count = nil
        return nil, nil
      end

      if @redirect_count > MAX_REDIRECTS
        @redirect_count = nil
        return nil, nil
      end

      src = '', charset = nil

      begin
        uri = Addressable::URI.parse(uri.to_s)

        if uri.scheme == 'file'
          # local file
          path = uri.path
          path.gsub!(/^\//, '') if Gem.win_platform?
          fh = open(path, 'rb')
          src = fh.read
          charset = fh.respond_to?(:charset) ? fh.charset : 'utf-8'
          fh.close
        else
          # remote file
          if uri.scheme == 'https'
            uri.port = 443 unless uri.port
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          else
            http = Net::HTTP.new(uri.host, uri.port)
          end

          res = http.get(uri.request_uri, {'User-Agent' => USER_AGENT, 'Accept-Encoding' => 'gzip'})
          src = res.body
          charset = res.respond_to?(:charset) ? res.encoding : 'utf-8'

          if res.code.to_i >= 400
            @redirect_count = nil
            raise RemoteFileError.new(uri.to_s) if @options[:io_exceptions]
            return '', nil
          elsif res.code.to_i >= 300 and res.code.to_i < 400
            if res['Location'] != nil
              return read_remote_file Addressable::URI.parse(Addressable::URI.escape(res['Location']))
            end
          end

          case res['content-encoding']
            when 'gzip'
              io = Zlib::GzipReader.new(StringIO.new(res.body))
              src = io.read
            when 'deflate'
              io = Zlib::Inflate.new
              src = io.inflate(res.body)
          end
        end

        if charset
          if String.method_defined?(:encode)
            src.encode!('UTF-8', charset)
          else
            ic = Iconv.new('UTF-8//IGNORE', charset)
            src = ic.iconv(src)
          end
        end
      rescue
        @redirect_count = nil
        raise RemoteFileError.new(uri.to_s)if @options[:io_exceptions]
        return nil, nil
      end

      @redirect_count = nil
      return src, charset
    end

  private
    # Save a folded declaration block to the internal cache.
    def save_folded_declaration(block_hash, folded_declaration) # :nodoc:
      @folded_declaration_cache[block_hash] = folded_declaration
    end

    # Retrieve a folded declaration block from the internal cache.
    def get_folded_declaration(block_hash) # :nodoc:
      return @folded_declaration_cache[block_hash] ||= nil
    end

    def reset! # :nodoc:
      @folded_declaration_cache = {}
      @css_source = ''
      @css_rules = []
      @css_warnings = []
    end

    # recurse through nested nodes and return them as Hashes nested in
    # passed hash
    def css_node_to_h(hash, key, val)
      hash[key.strip] = '' and return hash if val.nil?
      lines = val.split(';')
      nodes = {}
      lines.each do |line|
        parts = line.split(':', 2)
        if (parts[1] =~ /:/)
          nodes[parts[0]] = css_node_to_h(hash, parts[0], parts[1])
        else
          nodes[parts[0].to_s.strip] =parts[1].to_s.strip
        end
      end
      hash[key.strip] = nodes
      hash
    end
  end
end
