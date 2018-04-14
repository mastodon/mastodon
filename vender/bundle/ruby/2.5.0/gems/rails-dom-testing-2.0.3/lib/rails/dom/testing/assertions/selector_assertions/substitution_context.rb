class SubstitutionContext
  def initialize
    @substitute = '?'
  end

  def substitute!(selector, values, format_for_presentation = false)
    selector = selector.dup

    while !values.empty? && substitutable?(values.first) && selector.index(@substitute)
      selector.sub! @substitute, matcher_for(values.shift, format_for_presentation)
    end

    selector
  end

  def match(matches, attribute, matcher)
    matches.find_all { |node| node[attribute] =~ Regexp.new(matcher) }
  end

  private
    def matcher_for(value, format_for_presentation)
      # Nokogiri doesn't like arbitrary values without quotes, hence inspect.
      if format_for_presentation
        value.inspect # Avoid to_s so Regexps aren't put in quotes.
      else
        value.to_s.inspect
      end
    end

    def substitutable?(value)
      value.is_a?(String) || value.is_a?(Regexp)
    end
end
