require 'addressable/uri'
require 'uri'
require 'net/https'
require 'digest/md5'
require 'zlib'
require 'stringio'
require 'iconv' unless String.method_defined?(:encode)

require 'css_parser/version'
require 'css_parser/rule_set'
require 'css_parser/regexps'
require 'css_parser/parser'

module CssParser

  # Merge multiple CSS RuleSets by cascading according to the CSS 2.1 cascading rules
  # (http://www.w3.org/TR/REC-CSS2/cascade.html#cascading-order).
  #
  # Takes one or more RuleSet objects.
  #
  # Returns a RuleSet.
  #
  # ==== Cascading
  # If a RuleSet object has its +specificity+ defined, that specificity is
  # used in the cascade calculations.
  #
  # If no specificity is explicitly set and the RuleSet has *one* selector,
  # the specificity is calculated using that selector.
  #
  # If no selectors the specificity is treated as 0.
  #
  # If multiple selectors are present then the greatest specificity is used.
  #
  # ==== Example #1
  #   rs1 = RuleSet.new(nil, 'color: black;')
  #   rs2 = RuleSet.new(nil, 'margin: 0px;')
  #
  #   merged = CssParser.merge(rs1, rs2)
  #
  #   puts merged
  #   => "{ margin: 0px; color: black; }"
  #
  # ==== Example #2
  #   rs1 = RuleSet.new(nil, 'background-color: black;')
  #   rs2 = RuleSet.new(nil, 'background-image: none;')
  #
  #   merged = CssParser.merge(rs1, rs2)
  #
  #   puts merged
  #   => "{ background: none black; }"
  #--
  # TODO: declaration_hashes should be able to contain a RuleSet
  #       this should be a Class method
  def self.merge(*rule_sets)
    @folded_declaration_cache = {}

    # in case called like CssParser.merge([rule_set, rule_set])
    rule_sets.flatten! if rule_sets[0].kind_of?(Array)

    unless rule_sets.all? {|rs| rs.kind_of?(CssParser::RuleSet)}
      raise ArgumentError, "all parameters must be CssParser::RuleSets."
    end

    return rule_sets[0] if rule_sets.length == 1

    # Internal storage of CSS properties that we will keep
    properties = {}

    rule_sets.each do |rule_set|
      rule_set.expand_shorthand!

      specificity = rule_set.specificity
      unless specificity
        if rule_set.selectors.length == 0
          specificity = 0
        else
          specificity = rule_set.selectors.map { |s| calculate_specificity(s) }.compact.max || 0
        end
      end

      rule_set.each_declaration do |property, value, is_important|
        # Add the property to the list to be folded per http://www.w3.org/TR/CSS21/cascade.html#cascading-order
        if not properties.has_key?(property)
          properties[property] = {:value => value, :specificity => specificity, :is_important => is_important}
        elsif is_important
          if not properties[property][:is_important] or properties[property][:specificity] <= specificity
            properties[property] = {:value => value, :specificity => specificity, :is_important => is_important}
          end
        elsif properties[property][:specificity] < specificity or properties[property][:specificity] == specificity
          unless properties[property][:is_important]
            properties[property] = {:value => value, :specificity => specificity, :is_important => is_important}
          end
        end
     end
    end

    merged = RuleSet.new(nil, nil)

    properties.each do |property, details|
      if details[:is_important]
        merged[property.strip] = details[:value].strip.gsub(/\;\Z/, '') + '!important'
      else
        merged[property.strip] = details[:value].strip
      end
    end

    merged.create_shorthand!
    merged
  end

  # Calculates the specificity of a CSS selector
  # per http://www.w3.org/TR/CSS21/cascade.html#specificity
  #
  # Returns an integer.
  #
  # ==== Example
  #  CssParser.calculate_specificity('#content div p:first-line a:link')
  #  => 114
  #--
  # Thanks to Rafael Salazar and Nick Fitzsimons on the css-discuss list for their help.
  #++
  def self.calculate_specificity(selector)
    a = 0
    b = selector.scan(/\#/).length
    c = selector.scan(NON_ID_ATTRIBUTES_AND_PSEUDO_CLASSES_RX).length
    d = selector.scan(ELEMENTS_AND_PSEUDO_ELEMENTS_RX).length

    (a.to_s + b.to_s + c.to_s + d.to_s).to_i
  rescue
    return 0
  end

  # Make <tt>url()</tt> links absolute.
  #
  # Takes a block of CSS and returns it with all relative URIs converted to absolute URIs.
  #
  # "For CSS style sheets, the base URI is that of the style sheet, not that of the source document."
  # per http://www.w3.org/TR/CSS21/syndata.html#uri
  #
  # Returns a string.
  #
  # ==== Example
  #  CssParser.convert_uris("body { background: url('../style/yellow.png?abc=123') };",
  #               "http://example.org/style/basic.css").inspect
  #  => "body { background: url('http://example.org/style/yellow.png?abc=123') };"
  def self.convert_uris(css, base_uri)
    base_uri = Addressable::URI.parse(base_uri) unless base_uri.kind_of?(Addressable::URI)

    css.gsub(URI_RX) do
      uri = $1.to_s
      uri.gsub!(/["']+/, '')
      # Don't process URLs that are already absolute
      unless uri =~ /^[a-z]+\:\/\//i
        begin
          uri = base_uri + uri
        rescue; end
      end
      "url('#{uri.to_s}')"
    end
  end

  def self.sanitize_media_query(raw)
    mq = raw.to_s.gsub(/[\s]+/, ' ').strip
    mq = 'all' if mq.empty?
    mq.to_sym
  end
end
