module CssParser
  class RuleSet
    # Patterns for specificity calculations
    RE_ELEMENTS_AND_PSEUDO_ELEMENTS = /((^|[\s\+\>]+)[\w]+|\:(first\-line|first\-letter|before|after))/i
    RE_NON_ID_ATTRIBUTES_AND_PSEUDO_CLASSES = /(\.[\w]+)|(\[[\w]+)|(\:(link|first\-child|lang))/i

    BACKGROUND_PROPERTIES = ['background-color', 'background-image', 'background-repeat', 'background-position', 'background-size', 'background-attachment']
    LIST_STYLE_PROPERTIES = ['list-style-type', 'list-style-position', 'list-style-image']

    # Array of selector strings.
    attr_reader   :selectors

    # Integer with the specificity to use for this RuleSet.
    attr_accessor   :specificity

    def initialize(selectors, block, specificity = nil)
      @selectors = []
      @specificity = specificity
      @declarations = {}
      @order = 0
      parse_selectors!(selectors) if selectors
      parse_declarations!(block)
    end

    # Get the value of a property
    def get_value(property)
      return '' unless property and not property.empty?

      property = property.downcase.strip
      properties = @declarations.inject('') do |val, (key, data)|
        #puts "COMPARING #{key} #{key.inspect} against #{property} #{property.inspect}"
        importance = data[:is_important] ? ' !important' : ''
        val << "#{data[:value]}#{importance}; " if key.downcase.strip == property
        val
      end
      return properties ? properties.strip : ''
    end
    alias_method :[], :get_value

    # Add a CSS declaration to the current RuleSet.
    #
    #  rule_set.add_declaration!('color', 'blue')
    #
    #  puts rule_set['color']
    #  => 'blue;'
    #
    #  rule_set.add_declaration!('margin', '0px auto !important')
    #
    #  puts rule_set['margin']
    #  => '0px auto !important;'
    #
    # If the property already exists its value will be over-written.
    def add_declaration!(property, value)
      if value.nil? or value.empty?
        @declarations.delete(property)
        return
      end

      value.gsub!(/;\Z/, '')
      is_important = !value.gsub!(CssParser::IMPORTANT_IN_PROPERTY_RX, '').nil?
      property = property.downcase.strip
      #puts "SAVING #{property}  #{value} #{is_important.inspect}"
      @declarations[property] = {
        :value => value, :is_important => is_important, :order => @order += 1
      }
    end
    alias_method :[]=, :add_declaration!

    # Remove CSS declaration from the current RuleSet.
    #
    #  rule_set.remove_declaration!('color')
    def remove_declaration!(property)
      @declarations.delete(property)
    end

    # Iterate through selectors.
    #
    # Options
    # -  +force_important+ -- boolean
    #
    # ==== Example
    #   ruleset.each_selector do |sel, dec, spec|
    #     ...
    #   end
    def each_selector(options = {}) # :yields: selector, declarations, specificity
      declarations = declarations_to_s(options)
      if @specificity
        @selectors.each { |sel| yield sel.strip, declarations, @specificity }
      else
        @selectors.each { |sel| yield sel.strip, declarations, CssParser.calculate_specificity(sel) }
      end
    end

    # Iterate through declarations.
    def each_declaration # :yields: property, value, is_important
      decs = @declarations.sort { |a,b| a[1][:order].nil? || b[1][:order].nil? ? 0 : a[1][:order] <=> b[1][:order] }
      decs.each do |property, data|
        value = data[:value]
        yield property.downcase.strip, value.strip, data[:is_important]
      end
    end

    # Return all declarations as a string.
    #--
    # TODO: Clean-up regexp doesn't seem to work
    #++
    def declarations_to_s(options = {})
     options = {:force_important => false}.merge(options)
     str = ''
     each_declaration do |prop, val, is_important|
       importance = (options[:force_important] || is_important) ? ' !important' : ''
       str += "#{prop}: #{val}#{importance}; "
     end
     str.gsub(/^[\s^(\{)]+|[\n\r\f\t]*|[\s]+$/mx, '').strip
    end

    # Return the CSS rule set as a string.
    def to_s
      decs = declarations_to_s
      "#{@selectors.join(',')} { #{decs} }"
    end

    # Split shorthand declarations (e.g. +margin+ or +font+) into their constituent parts.
    def expand_shorthand!
      # border must be expanded before dimensions
      expand_border_shorthand!
      expand_dimensions_shorthand!
      expand_font_shorthand!
      expand_background_shorthand!
      expand_list_style_shorthand!
    end

    # Convert shorthand background declarations (e.g. <tt>background: url("chess.png") gray 50% repeat fixed;</tt>)
    # into their constituent parts.
    #
    # See http://www.w3.org/TR/CSS21/colors.html#propdef-background
    def expand_background_shorthand! # :nodoc:
      return unless @declarations.has_key?('background')

      value = @declarations['background'][:value]

      if value =~ CssParser::RE_INHERIT
        BACKGROUND_PROPERTIES.each do |prop|
          split_declaration('background', prop, 'inherit')
        end
      end

      split_declaration('background', 'background-image', value.slice!(Regexp.union(CssParser::URI_RX, CssParser::RE_GRADIENT, /none/i)))
      split_declaration('background', 'background-attachment', value.slice!(CssParser::RE_SCROLL_FIXED))
      split_declaration('background', 'background-repeat', value.slice!(CssParser::RE_REPEAT))
      split_declaration('background', 'background-color', value.slice!(CssParser::RE_COLOUR))
      split_declaration('background', 'background-size', extract_background_size_from(value))
      split_declaration('background', 'background-position', value.slice(CssParser::RE_BACKGROUND_POSITION))

      @declarations.delete('background')
    end

    def extract_background_size_from(value)
      size = value.slice!(CssParser::RE_BACKGROUND_SIZE)

      size.sub(/^\s*\/\s*/, '') if size
    end

    # Split shorthand border declarations (e.g. <tt>border: 1px red;</tt>)
    # Additional splitting happens in expand_dimensions_shorthand!
    def expand_border_shorthand! # :nodoc:
      ['border', 'border-left', 'border-right', 'border-top', 'border-bottom'].each do |k|
        next unless @declarations.has_key?(k)

        value = @declarations[k][:value]

        split_declaration(k, "#{k}-width", value.slice!(CssParser::RE_BORDER_UNITS))
        split_declaration(k, "#{k}-color", value.slice!(CssParser::RE_COLOUR))
        split_declaration(k, "#{k}-style", value.slice!(CssParser::RE_BORDER_STYLE))

        @declarations.delete(k)
      end
    end

    # Split shorthand dimensional declarations (e.g. <tt>margin: 0px auto;</tt>)
    # into their constituent parts.  Handles margin, padding, border-color, border-style and border-width.
    def expand_dimensions_shorthand! # :nodoc:
      {'margin'       => 'margin-%s',
       'padding'      => 'padding-%s',
       'border-color' => 'border-%s-color',
       'border-style' => 'border-%s-style',
       'border-width' => 'border-%s-width'}.each do |property, expanded|

        next unless @declarations.has_key?(property)

        value = @declarations[property][:value]

        # RGB and HSL values in borders are the only units that can have spaces (within params).
        # We cheat a bit here by stripping spaces after commas in RGB and HSL values so that we
        # can split easily on spaces.
        #
        # TODO: rgba, hsl, hsla
        value.gsub!(RE_COLOUR) { |c| c.gsub(/(\s*\,\s*)/, ',') }

        matches = value.strip.split(/\s+/)

        t, r, b, l = nil

        case matches.length
          when 1
            t, r, b, l = matches[0], matches[0], matches[0], matches[0]
          when 2
            t, b = matches[0], matches[0]
            r, l = matches[1], matches[1]
          when 3
            t =  matches[0]
            r, l = matches[1], matches[1]
            b =  matches[2]
          when 4
            t =  matches[0]
            r = matches[1]
            b =  matches[2]
            l = matches[3]
        end

        split_declaration(property, expanded % 'top', t)
        split_declaration(property, expanded % 'right', r)
        split_declaration(property, expanded % 'bottom', b)
        split_declaration(property, expanded % 'left', l)

        @declarations.delete(property)
      end
    end

    # Convert shorthand font declarations (e.g. <tt>font: 300 italic 11px/14px verdana, helvetica, sans-serif;</tt>)
    # into their constituent parts.
    def expand_font_shorthand! # :nodoc:
      return unless @declarations.has_key?('font')

      font_props = {}

      # reset properties to 'normal' per http://www.w3.org/TR/CSS21/fonts.html#font-shorthand
      ['font-style', 'font-variant', 'font-weight', 'font-size',
       'line-height'].each do |prop|
        font_props[prop] = 'normal'
       end

      value = @declarations['font'][:value]
      value.gsub!(/\/\s+/, '/') # handle spaces between font size and height shorthand (e.g. 14px/ 16px)
      is_important = @declarations['font'][:is_important]
      order = @declarations['font'][:order]

      in_fonts = false

      matches = value.scan(/("(.*[^"])"|'(.*[^'])'|(\w[^ ,]+))/)
      matches.each do |match|
        m = match[0].to_s.strip
        m.gsub!(/[;]$/, '')

        if in_fonts
          if font_props.has_key?('font-family')
            font_props['font-family'] += ', ' + m
          else
            font_props['font-family'] = m
          end
        elsif m =~ /normal|inherit/i
          ['font-style', 'font-weight', 'font-variant'].each do |font_prop|
            font_props[font_prop] = m unless font_props.has_key?(font_prop)
          end
        elsif m =~ /italic|oblique/i
          font_props['font-style'] = m
        elsif m =~ /small\-caps/i
          font_props['font-variant'] = m
        elsif m =~ /[1-9]00$|bold|bolder|lighter/i
          font_props['font-weight'] = m
        elsif m =~ CssParser::FONT_UNITS_RX
          if m =~ /\//
            font_props['font-size'], font_props['line-height'] = m.split('/')
          else
            font_props['font-size'] = m
          end
          in_fonts = true
        end
      end

      font_props.each { |font_prop, font_val| @declarations[font_prop] = {:value => font_val, :is_important => is_important, :order => order} }

      @declarations.delete('font')
    end

    # Convert shorthand list-style declarations (e.g. <tt>list-style: lower-alpha outside;</tt>)
    # into their constituent parts.
    #
    # See http://www.w3.org/TR/CSS21/generate.html#lists
    def expand_list_style_shorthand! # :nodoc:
      return unless @declarations.has_key?('list-style')

      value = @declarations['list-style'][:value]

      if value =~ CssParser::RE_INHERIT
        LIST_STYLE_PROPERTIES.each do |prop|
          split_declaration('list-style', prop, 'inherit')
        end
      end

      split_declaration('list-style', 'list-style-type', value.slice!(CssParser::RE_LIST_STYLE_TYPE))
      split_declaration('list-style', 'list-style-position', value.slice!(CssParser::RE_INSIDE_OUTSIDE))
      split_declaration('list-style', 'list-style-image', value.slice!(Regexp.union(CssParser::URI_RX, /none/i)))

      @declarations.delete('list-style')
    end

    # Create shorthand declarations (e.g. +margin+ or +font+) whenever possible.
    def create_shorthand!
      create_background_shorthand!
      create_dimensions_shorthand!
      # border must be shortened after dimensions
      create_border_shorthand!
      create_font_shorthand!
      create_list_style_shorthand!
    end

    # Combine several properties into a shorthand one
    def create_shorthand_properties! properties, shorthand_property # :nodoc:
      values = []
      properties_to_delete = []
      properties.each do |property|
        if @declarations.has_key?(property) and not @declarations[property][:is_important]
          values << @declarations[property][:value]
          properties_to_delete << property
        end
      end

      if values.length > 1
        properties_to_delete.each do |property|
          @declarations.delete(property)
        end

        @declarations[shorthand_property] = {:value => values.join(' ')}
      end
    end

    # Looks for long format CSS background properties (e.g. <tt>background-color</tt>) and
    # converts them into a shorthand CSS <tt>background</tt> property.
    #
    # Leaves properties declared !important alone.
    def create_background_shorthand! # :nodoc:
      # When we have a background-size property we must separate it and distinguish it from
      # background-position by preceding it with a backslash. In this case we also need to
      # have a background-position property, so we set it if it's missing.
      # http://www.w3schools.com/cssref/css3_pr_background.asp
      if @declarations.has_key?('background-size') and not @declarations['background-size'][:is_important]
        unless @declarations.has_key?('background-position')
          @declarations['background-position'] = {:value => '0% 0%'}
        end

        @declarations['background-size'][:value] = "/ #{@declarations['background-size'][:value]}"
      end

      create_shorthand_properties! BACKGROUND_PROPERTIES, 'background'
    end

    # Combine border-color, border-style and border-width into border
    # Should be run after create_dimensions_shorthand!
    #
    # TODO: this is extremely similar to create_background_shorthand! and should be combined
    def create_border_shorthand! # :nodoc:
      values = []

      ['border-width', 'border-style', 'border-color'].each do |property|
        if @declarations.has_key?(property) and not @declarations[property][:is_important]
          # can't merge if any value contains a space (i.e. has multiple values)
          # we temporarily remove any spaces after commas for the check (inside rgba, etc...)
          return if @declarations[property][:value].gsub(/\,[\s]/, ',').strip =~ /[\s]/
          values << @declarations[property][:value]
        end
      end

      @declarations.delete('border-width')
      @declarations.delete('border-style')
      @declarations.delete('border-color')

      unless values.empty?
        @declarations['border'] = {:value => values.join(' ')}
      end
    end

    # Looks for long format CSS dimensional properties (margin, padding, border-color, border-style and border-width)
    # and converts them into shorthand CSS properties.
    def create_dimensions_shorthand! # :nodoc:
      directions = ['top', 'right', 'bottom', 'left']

      {'margin'       => 'margin-%s',
       'padding'      => 'padding-%s',
       'border-color' => 'border-%s-color',
       'border-style' => 'border-%s-style',
       'border-width' => 'border-%s-width'}.each do |property, expanded|

        top, right, bottom, left = ['top', 'right', 'bottom', 'left'].map { |side| expanded % side }
        foldable = @declarations.select do |dim, val|
          dim == top or dim == right or dim == bottom or dim == left
        end
        # All four dimensions must be present
        if foldable.length == 4
          values = {}

          directions.each { |d| values[d.to_sym] = @declarations[expanded % d][:value].downcase.strip }

          if values[:left] == values[:right]
            if values[:top] == values[:bottom]
              if values[:top] == values[:left] # All four sides are equal
                new_value = values[:top]
              else # Top and bottom are equal, left and right are equal
                new_value = values[:top] + ' ' + values[:left]
              end
            else # Only left and right are equal
              new_value = values[:top] + ' ' + values[:left] + ' ' + values[:bottom]
            end
          else # No sides are equal
            new_value = values[:top] + ' ' + values[:right] + ' ' + values[:bottom] + ' ' + values[:left]
          end

          new_value.strip!
          @declarations[property] = {:value => new_value.strip} unless new_value.empty?

          # Delete the longhand values
          directions.each { |d| @declarations.delete(expanded % d) }
        end
      end
    end


    # Looks for long format CSS font properties (e.g. <tt>font-weight</tt>) and
    # tries to convert them into a shorthand CSS <tt>font</tt> property.  All
    # font properties must be present in order to create a shorthand declaration.
    def create_font_shorthand! # :nodoc:
      ['font-style', 'font-variant', 'font-weight', 'font-size',
       'line-height', 'font-family'].each do |prop|
        return unless @declarations.has_key?(prop)
      end

      new_value = ''
      ['font-style', 'font-variant', 'font-weight'].each do |property|
        unless @declarations[property][:value] == 'normal'
          new_value += @declarations[property][:value] + ' '
        end
      end

      new_value += @declarations['font-size'][:value]

      unless @declarations['line-height'][:value] == 'normal'
        new_value += '/' + @declarations['line-height'][:value]
      end

      new_value += ' ' + @declarations['font-family'][:value]

      @declarations['font'] = {:value => new_value.gsub(/[\s]+/, ' ').strip}

      ['font-style', 'font-variant', 'font-weight', 'font-size',
       'line-height', 'font-family'].each do |prop|
       @declarations.delete(prop)
      end

    end

    # Looks for long format CSS list-style properties (e.g. <tt>list-style-type</tt>) and
    # converts them into a shorthand CSS <tt>list-style</tt> property.
    #
    # Leaves properties declared !important alone.
    def create_list_style_shorthand! # :nodoc:
      create_shorthand_properties! LIST_STYLE_PROPERTIES, 'list-style'
    end

  private

    # utility method for re-assign shorthand elements to longhand versions
    def split_declaration(src, dest, v)  # :nodoc:
      return unless v and not v.empty?

      if @declarations.has_key?(dest)
        #puts "dest #{dest} already exists"

        if @declarations[src][:order].nil? || (!@declarations[dest][:order].nil? && @declarations[dest][:order] > @declarations[src][:order])
          #puts "skipping #{dest}:#{v} due to order "
          return
        else
          @declarations[dest] = {}
        end
      end
      @declarations[dest] = @declarations[src].merge({:value => v.to_s.strip})
    end

    def parse_declarations!(block) # :nodoc:
      @declarations = {}

      return unless block

      block.gsub!(/(^[\s]*)|([\s]*$)/, '')

      continuation = ''
      block.split(/[\;$]+/m).each do |decs|
        decs = continuation + decs
        if decs =~ /\([^)]*\Z/ # if it has an unmatched parenthesis
          continuation = decs + ';'

        elsif matches = decs.match(/(.[^:]*)\s*:\s*(.+)(;?\s*\Z)/i)
          property, value, = matches.captures # skip end_of_declaration

          add_declaration!(property, value)
          continuation = ''
        end
      end
    end

    #--
    # TODO: way too simplistic
    #++
    def parse_selectors!(selectors) # :nodoc:
      @selectors = selectors.split(',').map { |s| s.gsub(/\s+/, ' ').strip }
    end
  end

  class OffsetAwareRuleSet < RuleSet

    # File offset range
    attr_reader :offset

    # the local or remote location
    attr_accessor :filename

    def initialize(filename, offset, selectors, block, specificity = nil)
      super(selectors, block, specificity)
      @offset = offset
      @filename = filename
    end
  end
end
