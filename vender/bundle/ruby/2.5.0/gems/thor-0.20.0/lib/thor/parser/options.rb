class Thor
  class Options < Arguments #:nodoc: # rubocop:disable ClassLength
    LONG_RE     = /^(--\w+(?:-\w+)*)$/
    SHORT_RE    = /^(-[a-z])$/i
    EQ_RE       = /^(--\w+(?:-\w+)*|-[a-z])=(.*)$/i
    SHORT_SQ_RE = /^-([a-z]{2,})$/i # Allow either -x -v or -xv style for single char args
    SHORT_NUM   = /^(-[a-z])#{NUMERIC}$/i
    OPTS_END    = "--".freeze

    # Receives a hash and makes it switches.
    def self.to_switches(options)
      options.map do |key, value|
        case value
        when true
          "--#{key}"
        when Array
          "--#{key} #{value.map(&:inspect).join(' ')}"
        when Hash
          "--#{key} #{value.map { |k, v| "#{k}:#{v}" }.join(' ')}"
        when nil, false
          nil
        else
          "--#{key} #{value.inspect}"
        end
      end.compact.join(" ")
    end

    # Takes a hash of Thor::Option and a hash with defaults.
    #
    # If +stop_on_unknown+ is true, #parse will stop as soon as it encounters
    # an unknown option or a regular argument.
    def initialize(hash_options = {}, defaults = {}, stop_on_unknown = false, disable_required_check = false)
      @stop_on_unknown = stop_on_unknown
      @disable_required_check = disable_required_check
      options = hash_options.values
      super(options)

      # Add defaults
      defaults.each do |key, value|
        @assigns[key.to_s] = value
        @non_assigned_required.delete(hash_options[key])
      end

      @shorts = {}
      @switches = {}
      @extra = []

      options.each do |option|
        @switches[option.switch_name] = option

        option.aliases.each do |short|
          name = short.to_s.sub(/^(?!\-)/, "-")
          @shorts[name] ||= option.switch_name
        end
      end
    end

    def remaining
      @extra
    end

    def peek
      return super unless @parsing_options

      result = super
      if result == OPTS_END
        shift
        @parsing_options = false
        super
      else
        result
      end
    end

    def parse(args) # rubocop:disable MethodLength
      @pile = args.dup
      @parsing_options = true

      while peek
        if parsing_options?
          match, is_switch = current_is_switch?
          shifted = shift

          if is_switch
            case shifted
            when SHORT_SQ_RE
              unshift($1.split("").map { |f| "-#{f}" })
              next
            when EQ_RE, SHORT_NUM
              unshift($2)
              switch = $1
            when LONG_RE, SHORT_RE
              switch = $1
            end

            switch = normalize_switch(switch)
            option = switch_option(switch)
            @assigns[option.human_name] = parse_peek(switch, option)
          elsif @stop_on_unknown
            @parsing_options = false
            @extra << shifted
            @extra << shift while peek
            break
          elsif match
            @extra << shifted
            @extra << shift while peek && peek !~ /^-/
          else
            @extra << shifted
          end
        else
          @extra << shift
        end
      end

      check_requirement! unless @disable_required_check

      assigns = Thor::CoreExt::HashWithIndifferentAccess.new(@assigns)
      assigns.freeze
      assigns
    end

    def check_unknown!
      # an unknown option starts with - or -- and has no more --'s afterward.
      unknown = @extra.select { |str| str =~ /^--?(?:(?!--).)*$/ }
      raise UnknownArgumentError, "Unknown switches '#{unknown.join(', ')}'" unless unknown.empty?
    end

  protected

    # Check if the current value in peek is a registered switch.
    #
    # Two booleans are returned.  The first is true if the current value
    # starts with a hyphen; the second is true if it is a registered switch.
    def current_is_switch?
      case peek
      when LONG_RE, SHORT_RE, EQ_RE, SHORT_NUM
        [true, switch?($1)]
      when SHORT_SQ_RE
        [true, $1.split("").any? { |f| switch?("-#{f}") }]
      else
        [false, false]
      end
    end

    def current_is_switch_formatted?
      case peek
      when LONG_RE, SHORT_RE, EQ_RE, SHORT_NUM, SHORT_SQ_RE
        true
      else
        false
      end
    end

    def current_is_value?
      peek && (!parsing_options? || super)
    end

    def switch?(arg)
      switch_option(normalize_switch(arg))
    end

    def switch_option(arg)
      if match = no_or_skip?(arg) # rubocop:disable AssignmentInCondition
        @switches[arg] || @switches["--#{match}"]
      else
        @switches[arg]
      end
    end

    # Check if the given argument is actually a shortcut.
    #
    def normalize_switch(arg)
      (@shorts[arg] || arg).tr("_", "-")
    end

    def parsing_options?
      peek
      @parsing_options
    end

    # Parse boolean values which can be given as --foo=true, --foo or --no-foo.
    #
    def parse_boolean(switch)
      if current_is_value?
        if ["true", "TRUE", "t", "T", true].include?(peek)
          shift
          true
        elsif ["false", "FALSE", "f", "F", false].include?(peek)
          shift
          false
        else
          !no_or_skip?(switch)
        end
      else
        @switches.key?(switch) || !no_or_skip?(switch)
      end
    end

    # Parse the value at the peek analyzing if it requires an input or not.
    #
    def parse_peek(switch, option)
      if parsing_options? && (current_is_switch_formatted? || last?)
        if option.boolean?
          # No problem for boolean types
        elsif no_or_skip?(switch)
          return nil # User set value to nil
        elsif option.string? && !option.required?
          # Return the default if there is one, else the human name
          return option.lazy_default || option.default || option.human_name
        elsif option.lazy_default
          return option.lazy_default
        else
          raise MalformattedArgumentError, "No value provided for option '#{switch}'"
        end
      end

      @non_assigned_required.delete(option)
      send(:"parse_#{option.type}", switch)
    end
  end
end
