# encoding: utf-8

require 'crass'
require 'set'

class Sanitize; class CSS
  attr_reader :config

  # -- Class Methods -----------------------------------------------------------

  # Sanitizes inline CSS style properties.
  #
  # This is most useful for sanitizing non-stylesheet fragments of CSS like you
  # would find in the `style` attribute of an HTML element. To sanitize a full
  # CSS stylesheet, use {.stylesheet}.
  #
  # @example
  #   Sanitize::CSS.properties("background: url(foo.png); color: #fff;")
  #
  # @return [String] Sanitized CSS properties.
  def self.properties(css, config = {})
    self.new(config).properties(css)
  end

  # Sanitizes a full CSS stylesheet.
  #
  # A stylesheet may include selectors, at-rules, and comments. To sanitize only
  # inline style properties such as the contents of an HTML `style` attribute,
  # use {.properties}.
  #
  # @example
  #   css = %[
  #     .foo {
  #       background: url(foo.png);
  #       color: #fff;
  #     }
  #
  #     #bar {
  #       font: 42pt 'Comic Sans MS';
  #     }
  #   ]
  #
  #   Sanitize::CSS.stylesheet(css, Sanitize::Config::RELAXED)
  #
  # @return [String] Sanitized CSS stylesheet.
  def self.stylesheet(css, config = {})
    self.new(config).stylesheet(css)
  end

  # Sanitizes the given Crass CSS parse tree and all its children, modifying it
  # in place.
  #
  # @example
  #   css = %[
  #     .foo {
  #       background: url(foo.png);
  #       color: #fff;
  #     }
  #
  #     #bar {
  #       font: 42pt 'Comic Sans MS';
  #     }
  #   ]
  #
  #   tree = Crass.parse(css)
  #   Sanitize::CSS.tree!(tree, Sanitize::Config::RELAXED)
  #
  # @return [Array] Sanitized Crass CSS parse tree.
  def self.tree!(tree, config = {})
    self.new(config).tree!(tree)
  end

  # -- Instance Methods --------------------------------------------------------

  # Returns a new Sanitize::CSS object initialized with the settings in
  # _config_.
  def initialize(config = {})
    @config = Config.merge(Config::DEFAULT[:css], config[:css] || config)

    @at_rules                 = Set.new(@config[:at_rules])
    @at_rules_with_properties = Set.new(@config[:at_rules_with_properties])
    @at_rules_with_styles     = Set.new(@config[:at_rules_with_styles])
    @import_url_validator     = @config[:import_url_validator]
  end

  # Sanitizes inline CSS style properties.
  #
  # This is most useful for sanitizing non-stylesheet fragments of CSS like you
  # would find in the `style` attribute of an HTML element. To sanitize a full
  # CSS stylesheet, use {#stylesheet}.
  #
  # @example
  #   scss = Sanitize::CSS.new(Sanitize::Config::RELAXED)
  #   scss.properties("background: url(foo.png); color: #fff;")
  #
  # @return [String] Sanitized CSS properties.
  def properties(css)
    tree = Crass.parse_properties(css,
      :preserve_comments => @config[:allow_comments],
      :preserve_hacks    => @config[:allow_hacks])

    tree!(tree)
    Crass::Parser.stringify(tree)
  end

  # Sanitizes a full CSS stylesheet.
  #
  # A stylesheet may include selectors, at-rules, and comments. To sanitize only
  # inline style properties such as the contents of an HTML `style` attribute,
  # use {#properties}.
  #
  # @example
  #   css = %[
  #     .foo {
  #       background: url(foo.png);
  #       color: #fff;
  #     }
  #
  #     #bar {
  #       font: 42pt 'Comic Sans MS';
  #     }
  #   ]
  #
  #   scss = Sanitize::CSS.new(Sanitize::Config::RELAXED)
  #   scss.stylesheet(css)
  #
  # @return [String] Sanitized CSS stylesheet.
  def stylesheet(css)
    tree = Crass.parse(css,
      :preserve_comments => @config[:allow_comments],
      :preserve_hacks    => @config[:allow_hacks])

    tree!(tree)
    Crass::Parser.stringify(tree)
  end

  # Sanitizes the given Crass CSS parse tree and all its children, modifying it
  # in place.
  #
  # @example
  #   css = %[
  #     .foo {
  #       background: url(foo.png);
  #       color: #fff;
  #     }
  #
  #     #bar {
  #       font: 42pt 'Comic Sans MS';
  #     }
  #   ]
  #
  #   scss = Sanitize::CSS.new(Sanitize::Config::RELAXED)
  #   tree = Crass.parse(css)
  #
  #   scss.tree!(tree)
  #
  # @return [Array] Sanitized Crass CSS parse tree.
  def tree!(tree)
    preceded_by_property = false

    tree.map! do |node|
      next nil if node.nil?

      case node[:node]
      when :at_rule
        preceded_by_property = false
        next at_rule!(node)

      when :comment
        next node if @config[:allow_comments]

      when :property
        prop = property!(node)
        preceded_by_property = !prop.nil?
        next prop

      when :semicolon
        # Only preserve the semicolon if it was preceded by a whitelisted
        # property. Otherwise, omit it in order to prevent redundant semicolons.
        if preceded_by_property
          preceded_by_property = false
          next node
        end

      when :style_rule
        preceded_by_property = false
        tree!(node[:children])
        next node

      when :whitespace
        next node
      end

      nil
    end

    tree
  end

  # -- Protected Instance Methods ----------------------------------------------
  protected

  # Sanitizes a CSS at-rule node. Returns the sanitized node, or `nil` if the
  # current config doesn't allow this at-rule.
  def at_rule!(rule)
    name = rule[:name].downcase

    if @at_rules_with_styles.include?(name)
      styles = Crass::Parser.parse_rules(rule[:block],
        :preserve_comments => @config[:allow_comments],
        :preserve_hacks    => @config[:allow_hacks])

      rule[:block] = tree!(styles)

    elsif @at_rules_with_properties.include?(name)
      props = Crass::Parser.parse_properties(rule[:block],
        :preserve_comments => @config[:allow_comments],
        :preserve_hacks    => @config[:allow_hacks])

      rule[:block] = tree!(props)

    elsif @at_rules.include?(name)
      return nil if name == "import" && !import_url_allowed?(rule)
      return nil if rule.has_key?(:block)
    else
      return nil
    end

    rule
  end

  # Passes the URL value of an @import rule to a block to ensure
  # it's an allowed URL
  def import_url_allowed?(rule)
    return true unless @import_url_validator

    url_token = rule[:tokens].detect { |t| t[:node] == :url || t[:node] == :string }

    # don't allow @imports with no URL value
    return false unless url_token && (import_url = url_token[:value])

    @import_url_validator.call(import_url)
  end

  # Sanitizes a CSS property node. Returns the sanitized node, or `nil` if the
  # current config doesn't allow this property.
  def property!(prop)
    name = prop[:name].downcase

    # Preserve IE * and _ hacks if desired.
    if @config[:allow_hacks]
      name.slice!(0) if name =~ /\A[*_]/
    end

    return nil unless @config[:properties].include?(name)

    nodes          = prop[:children].dup
    combined_value = String.new

    nodes.each do |child|
      value = child[:value]

      case child[:node]
      when :ident
        combined_value << value.downcase if String === value

      when :function
        if child.key?(:name)
          name = child[:name].downcase

          if name == 'url'
            return nil unless valid_url?(child)
          end

          combined_value << name
          return nil if name == 'expression' || combined_value == 'expression'
        end

        if Array === value
          nodes.concat(value)
        elsif String === value
          lowercase_value = value.downcase
          combined_value << lowercase_value
          return nil if lowercase_value == 'expression' || combined_value == 'expression'
        end

      when :url
        return nil unless valid_url?(child)

      when :bad_url
        return nil
      end
    end

    prop
  end

  # Returns `true` if the given node (which may be of type `:url` or
  # `:function`, since the CSS syntax can produce both) uses a whitelisted
  # protocol.
  def valid_url?(node)
    type = node[:node]

    if type == :function
      return false unless node.key?(:name) && node[:name].downcase == 'url'
      return false unless Array === node[:value]

      # A URL function's `:value` should be an array containing no more than one
      # `:string` node and any number of `:whitespace` nodes.
      #
      # If it contains more than one `:string` node, or if it contains any other
      # nodes except `:whitespace` nodes, it's not valid.
      url_string_node = nil

      node[:value].each do |token|
        return false unless Hash === token

        case token[:node]
          when :string
            return false unless url_string_node.nil?
            url_string_node = token

          when :whitespace
            next

          else
            return false
        end
      end

      return false if url_string_node.nil?
      url = url_string_node[:value]
    elsif type == :url
      url = node[:value]
    else
      return false
    end

    if url =~ Sanitize::REGEX_PROTOCOL
      return @config[:protocols].include?($1.downcase)
    else
      return @config[:protocols].include?(:relative)
    end

    false
  end

end; end
