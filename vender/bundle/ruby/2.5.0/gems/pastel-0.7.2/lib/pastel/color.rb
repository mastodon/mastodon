# encoding: utf-8

require 'equatable'

require_relative 'ansi'

module Pastel
  # A class responsible for coloring strings.
  class Color
    include Equatable
    include ANSI

    # All color aliases
    ALIASES = {}

    # Match all color escape sequences
    ANSI_COLOR_REGEXP = /\x1b+(\[|\[\[)[0-9;:?]+m/mo.freeze

    attr_reader :enabled
    alias_method :enabled?, :enabled

    attr_reader :eachline

    # Initialize a Terminal Color
    #
    # @api public
    def initialize(options = {})
      @enabled  = options[:enabled]
      @eachline = options.fetch(:eachline) { false }
      @cache    = {}
    end

    # Disable coloring of this terminal session
    #
    # @api public
    def disable!
      @enabled = false
    end

    # Apply ANSI color to the given string.
    #
    # Wraps eachline with clear escape.
    #
    # @param [String] string
    #   text to add ANSI strings
    #
    # @param [Array[Symbol]] colors
    #   the color names
    #
    # @example
    #   color.decorate "text", :yellow, :on_green, :underline
    #
    # @return [String]
    #   the colored string
    #
    # @api public
    def decorate(string, *colors)
      return string if blank?(string) || !enabled || colors.empty?

      ansi_colors = lookup(*colors.dup.uniq)
      if eachline
        string.dup.split(eachline).map! do |line|
          apply_codes(line, ansi_colors)
        end.join(eachline)
      else
        apply_codes(string.dup, ansi_colors)
      end
    end

    # Apply escape codes to the string
    #
    # @param [String] string
    #   the string to apply escapes to
    # @param [Strin] ansi_colors
    #   the ansi colors to apply
    #
    # @return [String]
    #   return the string surrounded by escape codes
    #
    # @api private
    def apply_codes(string, ansi_colors)
      "#{ansi_colors}#{string.gsub(/(\e\[0m)([^\e]+)$/, "\\1#{ansi_colors}\\2")}\e[0m"
    end

    # Reset sequence
    #
    # @api public
    def clear
      lookup(:clear)
    end

    # Strip ANSI color codes from a string.
    #
    # Only ANSI color codes are removed, not movement codes or
    # other escapes sequences are stripped.
    #
    # @param [Array[String]] strings
    #   a string or array of strings to sanitize
    #
    # @example
    #   strip("foo\e[1mbar\e[0m")  # => "foobar"
    #
    # @return [String]
    #
    # @api public
    def strip(*strings)
      modified = strings.map { |string| string.dup.gsub(ANSI_COLOR_REGEXP, '') }
      modified.size == 1 ? modified[0] : modified
    end

    # Check if string has color escape codes
    #
    # @param [String] string
    #   the string to check for color strings
    #
    # @return [Boolean]
    #   true when string contains color codes, false otherwise
    #
    # @api public
    def colored?(string)
      !ANSI_COLOR_REGEXP.match(string).nil?
    end

    # Find the escape code for a given set of color attributes
    #
    # @example
    #   color.lookup(:red, :on_green) # => "\e[31;42m"
    #
    # @param [Array[Symbol]] colors
    #   the list of color name(s) to lookup
    #
    # @return [String]
    #   the ANSI code(s)
    #
    # @raise [InvalidAttributeNameError]
    #   exception raised for any invalid color name
    #
    # @api private
    def lookup(*colors)
      @cache.fetch(colors) do
        @cache[colors] = "\e[#{code(*colors).join(';')}m"
      end
    end

    # Return raw color code without embeding it into a string.
    #
    # @return [Array[String]]
    #   ANSI escape codes
    #
    # @api public
    def code(*colors)
      attribute = []
      colors.each do |color|
        value = ANSI::ATTRIBUTES[color] || ALIASES[color]
        if value
          attribute << value
        else
          validate(color)
        end
      end
      attribute
    end

    # Expose all ANSI color names and their codes
    #
    # @return [Hash[Symbol]]
    #
    # @api public
    def styles
      ANSI::ATTRIBUTES.merge(ALIASES)
    end

    # List all available style names
    #
    # @return [Array[Symbol]]
    #
    # @api public
    def style_names
      styles.keys
    end

    # Check if provided colors are known colors
    #
    # @param [Array[Symbol,String]]
    #   the list of colors to check
    #
    # @example
    #   valid?(:red)   # => true
    #
    # @return [Boolean]
    #   true if all colors are valid, false otherwise
    #
    # @api public
    def valid?(*colors)
      colors.all? { |color| style_names.include?(color.to_sym) }
    end

    # Define a new colors alias
    #
    # @param [String] alias_name
    #   the colors alias to define
    # @param [Array[Symbol,String]] color
    #   the colors the alias will correspond to
    #
    # @return [Array[String]]
    #   the standard color values of the alias
    #
    # @api public
    def alias_color(alias_name, *colors)
      validate(*colors)

      if !(alias_name.to_s =~ /^[\w]+$/)
        fail InvalidAliasNameError, "Invalid alias name `#{alias_name}`"
      elsif ANSI::ATTRIBUTES[alias_name]
        fail InvalidAliasNameError,
             "Cannot alias standard color `#{alias_name}`"
      end

      ALIASES[alias_name.to_sym] = colors.map(&ANSI::ATTRIBUTES.method(:[]))
      colors
    end

    private

    # Check if value contains anything to style
    #
    # @return [Boolean]
    #
    # @api private
    def blank?(value)
      value.nil? || !value.respond_to?(:to_str) || value.to_s == ''
    end

    # @api private
    def validate(*colors)
      return if valid?(*colors)
      fail InvalidAttributeNameError, 'Bad style or unintialized constant, ' \
        " valid styles are: #{style_names.join(', ')}."
    end
  end # Color
end # TTY
